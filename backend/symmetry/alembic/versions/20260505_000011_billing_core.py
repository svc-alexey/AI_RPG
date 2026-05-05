"""Billing core: add columns, indexes, billing_orders, payment_events."""

import sqlalchemy as sa
from alembic import op

revision = "20260505_000011"
down_revision = "20260503_000010"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # billing_subscriptions — add new lifecycle columns (table exists from pre-alembic)
    for col_spec in [
        ("current_period_start_at", sa.DateTime(timezone=True), True),
        ("current_period_end_at", sa.DateTime(timezone=True), True),
        ("cancel_at_period_end", sa.Boolean(), False, "false"),
        ("payment_method_id", sa.String(length=512), True),
        ("monthly_quota_tokens", sa.Integer(), True),
        ("retry_count", sa.Integer(), False, "0"),
        ("last_retry_at", sa.DateTime(timezone=True), True),
        ("next_retry_at", sa.DateTime(timezone=True), True),
    ]:
        args = [col_spec[0], col_spec[1]]
        kwargs = {"nullable": col_spec[2]}
        if len(col_spec) > 3:
            kwargs["server_default"] = col_spec[3]
        op.add_column("billing_subscriptions", sa.Column(*args, **kwargs))

    op.create_index(
        "ix_billing_subscriptions_status_next_retry",
        "billing_subscriptions",
        ["status", "next_retry_at"],
    )

    # credit_ledger — add provider_payment_id + indexes (table exists from pre-alembic)
    op.add_column(
        "credit_ledger",
        sa.Column("provider_payment_id", sa.String(length=255), nullable=True, unique=True),
    )
    op.create_index(
        "ix_credit_ledger_user_reason_created",
        "credit_ledger",
        ["user_id", "reason", "created_at"],
    )
    # Convert JSON to JSONB for GIN support
    op.execute(sa.text("ALTER TABLE credit_ledger ALTER COLUMN metadata_json TYPE jsonb USING metadata_json::jsonb"))
    op.create_index(
        "ix_credit_ledger_metadata_gin",
        "credit_ledger",
        ["metadata_json"],
        postgresql_using="gin",
    )

    # payment_events — new table
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

    # billing_orders — new table
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


def downgrade() -> None:
    op.drop_index("ix_billing_orders_provider_payment_id")
    op.drop_index("ix_billing_orders_user_status")
    op.drop_table("billing_orders")
    op.drop_table("payment_events")
    op.drop_index("ix_credit_ledger_metadata_gin")
    op.drop_index("ix_credit_ledger_user_reason_created")
    op.execute(sa.text("ALTER TABLE credit_ledger ALTER COLUMN metadata_json TYPE json USING metadata_json::json"))
    op.drop_column("credit_ledger", "provider_payment_id")
    op.drop_index("ix_billing_subscriptions_status_next_retry")
    for col_name in [
        "next_retry_at", "last_retry_at", "retry_count",
        "monthly_quota_tokens", "payment_method_id",
        "cancel_at_period_end", "current_period_end_at", "current_period_start_at",
    ]:
        op.drop_column("billing_subscriptions", col_name)
