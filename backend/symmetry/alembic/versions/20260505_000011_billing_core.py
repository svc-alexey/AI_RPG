"""Billing core: billing_customers, billing_plans, billing_subscriptions, credit_ledger, payment_events, billing_orders."""

import sqlalchemy as sa
from alembic import op

revision = "20260505_000011"
down_revision = "20260503_000010"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # billing_customers
    op.create_table(
        "billing_customers",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column(
            "user_id",
            sa.String(36),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            unique=True,
            nullable=False,
        ),
        sa.Column("metadata_json", sa.JSON(), nullable=False, server_default="{}"),
    )

    # billing_plans
    op.create_table(
        "billing_plans",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column("code", sa.String(length=80), unique=True, nullable=False),
        sa.Column("title", sa.String(length=120), nullable=False),
        sa.Column("metadata_json", sa.JSON(), nullable=False, server_default="{}"),
    )

    # billing_subscriptions — includes plan columns + new subscription lifecycle fields
    op.create_table(
        "billing_subscriptions",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column(
            "billing_customer_id",
            sa.String(36),
            sa.ForeignKey("billing_customers.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column(
            "billing_plan_id",
            sa.String(36),
            sa.ForeignKey("billing_plans.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("status", sa.String(length=32), nullable=False, server_default="draft"),
        sa.Column("current_period_start_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("current_period_end_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("cancel_at_period_end", sa.Boolean(), nullable=False, server_default="false"),
        sa.Column("payment_method_id", sa.String(length=512), nullable=True),
        sa.Column("monthly_quota_tokens", sa.Integer(), nullable=True),
        sa.Column("retry_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("last_retry_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("next_retry_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("metadata_json", sa.JSON(), nullable=False, server_default="{}"),
    )

    # credit_ledger
    op.create_table(
        "credit_ledger",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column(
            "user_id",
            sa.String(36),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("amount", sa.Integer(), nullable=False),
        sa.Column("reason", sa.String(length=255), nullable=False),
        sa.Column("provider_payment_id", sa.String(length=255), nullable=True, unique=True),
        sa.Column("metadata_json", sa.JSON(), nullable=False, server_default="{}"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
    )

    op.create_index(
        "ix_credit_ledger_user_reason_created",
        "credit_ledger",
        ["user_id", "reason", "created_at"],
    )
    op.create_index(
        "ix_credit_ledger_metadata_gin",
        "credit_ledger",
        ["metadata_json"],
        postgresql_using="gin",
    )

    # payment_events
    op.create_table(
        "payment_events",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column(
            "billing_customer_id",
            sa.String(36),
            sa.ForeignKey("billing_customers.id", ondelete="SET NULL"),
            nullable=True,
        ),
        sa.Column("provider", sa.String(length=80), nullable=False),
        sa.Column("event_type", sa.String(length=120), nullable=False),
        sa.Column("payload_json", sa.JSON(), nullable=False, server_default="{}"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
    )

    # billing_orders — new table for checkout flow
    op.create_table(
        "billing_orders",
        sa.Column("id", sa.String(length=36), primary_key=True),
        sa.Column(
            "user_id",
            sa.String(36),
            sa.ForeignKey("users.id", ondelete="CASCADE"),
            nullable=False,
        ),
        sa.Column("plan_code", sa.String(length=80), nullable=False),
        sa.Column("provider", sa.String(length=80), nullable=False, server_default="yookassa"),
        sa.Column("provider_payment_id", sa.String(length=255), nullable=True),
        sa.Column("idempotency_key", sa.String(length=255), unique=True, nullable=False),
        sa.Column("amount_minor", sa.Integer(), nullable=False),
        sa.Column("currency", sa.String(length=3), nullable=False, server_default="RUB"),
        sa.Column("status", sa.String(length=32), nullable=False, server_default="pending"),
        sa.Column("confirmation_url", sa.String(length=2048), nullable=True),
        sa.Column("return_url", sa.String(length=2048), nullable=True),
        sa.Column("metadata_json", sa.JSON(), nullable=False, server_default="{}"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("now()"),
        ),
    )

    op.create_index(
        "ix_billing_orders_user_status",
        "billing_orders",
        ["user_id", "status"],
    )
    op.create_index(
        "ix_billing_orders_provider_payment_id",
        "billing_orders",
        ["provider_payment_id"],
    )
    op.create_index(
        "ix_billing_subscriptions_status_next_retry",
        "billing_subscriptions",
        ["status", "next_retry_at"],
    )


def downgrade() -> None:
    op.drop_index("ix_billing_subscriptions_status_next_retry")
    op.drop_index("ix_billing_orders_provider_payment_id")
    op.drop_index("ix_billing_orders_user_status")
    op.drop_table("billing_orders")
    op.drop_table("payment_events")
    op.drop_index("ix_credit_ledger_metadata_gin")
    op.drop_index("ix_credit_ledger_user_reason_created")
    op.drop_table("credit_ledger")
    op.drop_table("billing_subscriptions")
    op.drop_table("billing_plans")
    op.drop_table("billing_customers")
