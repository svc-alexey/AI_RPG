"""expand billing domain for yookassa, wallets, orders, and sale catalog."""

import sqlalchemy as sa
from alembic import op

revision = "20260426_000010"
down_revision = "20260417_000009"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column(
        "billing_customers",
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
    )
    op.alter_column("billing_customers", "created_at", server_default=None)

    op.add_column("billing_plans", sa.Column("kind", sa.String(length=32), nullable=False, server_default="token_pack"))
    op.add_column("billing_plans", sa.Column("description", sa.Text(), nullable=False, server_default=""))
    op.add_column("billing_plans", sa.Column("currency", sa.String(length=8), nullable=False, server_default="RUB"))
    op.add_column("billing_plans", sa.Column("base_price_minor", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("billing_plans", sa.Column("sale_price_minor", sa.Integer(), nullable=True))
    op.add_column("billing_plans", sa.Column("sale_badge_text", sa.String(length=80), nullable=False, server_default=""))
    op.add_column("billing_plans", sa.Column("sale_percent", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("billing_plans", sa.Column("sale_starts_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("billing_plans", sa.Column("sale_ends_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("billing_plans", sa.Column("is_active", sa.Boolean(), nullable=False, server_default="true"))
    op.add_column("billing_plans", sa.Column("token_grant", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("billing_plans", sa.Column("monthly_quota", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("billing_plans", sa.Column("fair_use_limit", sa.Integer(), nullable=False, server_default="0"))
    op.add_column("billing_plans", sa.Column("sort_order", sa.Integer(), nullable=False, server_default="0"))
    op.add_column(
        "billing_plans",
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
    )
    op.add_column(
        "billing_plans",
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
    )
    op.alter_column("billing_plans", "kind", server_default=None)
    op.alter_column("billing_plans", "description", server_default=None)
    op.alter_column("billing_plans", "currency", server_default=None)
    op.alter_column("billing_plans", "base_price_minor", server_default=None)
    op.alter_column("billing_plans", "sale_badge_text", server_default=None)
    op.alter_column("billing_plans", "sale_percent", server_default=None)
    op.alter_column("billing_plans", "is_active", server_default=None)
    op.alter_column("billing_plans", "token_grant", server_default=None)
    op.alter_column("billing_plans", "monthly_quota", server_default=None)
    op.alter_column("billing_plans", "fair_use_limit", server_default=None)
    op.alter_column("billing_plans", "sort_order", server_default=None)
    op.alter_column("billing_plans", "created_at", server_default=None)
    op.alter_column("billing_plans", "updated_at", server_default=None)

    op.add_column(
        "billing_subscriptions",
        sa.Column("provider", sa.String(length=32), nullable=False, server_default="yookassa"),
    )
    op.add_column(
        "billing_subscriptions",
        sa.Column("provider_subscription_ref", sa.String(length=128), nullable=False, server_default=""),
    )
    op.add_column(
        "billing_subscriptions",
        sa.Column("payment_method_id", sa.String(length=128), nullable=False, server_default=""),
    )
    op.add_column("billing_subscriptions", sa.Column("current_period_start_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("billing_subscriptions", sa.Column("current_period_end_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("billing_subscriptions", sa.Column("next_charge_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column(
        "billing_subscriptions",
        sa.Column("cancel_at_period_end", sa.Boolean(), nullable=False, server_default="false"),
    )
    op.add_column("billing_subscriptions", sa.Column("retry_count", sa.Integer(), nullable=False, server_default="0"))
    op.add_column(
        "billing_subscriptions",
        sa.Column("last_payment_id", sa.String(length=128), nullable=False, server_default=""),
    )
    op.add_column(
        "billing_subscriptions",
        sa.Column("last_failure_code", sa.String(length=128), nullable=False, server_default=""),
    )
    op.add_column(
        "billing_subscriptions",
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
    )
    op.add_column(
        "billing_subscriptions",
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
    )
    op.alter_column("billing_subscriptions", "provider", server_default=None)
    op.alter_column("billing_subscriptions", "provider_subscription_ref", server_default=None)
    op.alter_column("billing_subscriptions", "payment_method_id", server_default=None)
    op.alter_column("billing_subscriptions", "cancel_at_period_end", server_default=None)
    op.alter_column("billing_subscriptions", "retry_count", server_default=None)
    op.alter_column("billing_subscriptions", "last_payment_id", server_default=None)
    op.alter_column("billing_subscriptions", "last_failure_code", server_default=None)
    op.alter_column("billing_subscriptions", "created_at", server_default=None)
    op.alter_column("billing_subscriptions", "updated_at", server_default=None)

    op.create_table(
        "billing_wallets",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("welcome_tokens_remaining", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("paid_tokens_remaining", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("subscription_tokens_remaining", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("subscription_quota_resets_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("welcome_expires_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id"),
    )
    op.alter_column("billing_wallets", "welcome_tokens_remaining", server_default=None)
    op.alter_column("billing_wallets", "paid_tokens_remaining", server_default=None)
    op.alter_column("billing_wallets", "subscription_tokens_remaining", server_default=None)
    op.alter_column("billing_wallets", "created_at", server_default=None)
    op.alter_column("billing_wallets", "updated_at", server_default=None)

    op.create_table(
        "billing_orders",
        sa.Column("id", sa.String(length=36), nullable=False),
        sa.Column("user_id", sa.String(length=36), nullable=False),
        sa.Column("plan_code", sa.String(length=80), nullable=False),
        sa.Column("kind", sa.String(length=32), nullable=False, server_default="token_pack"),
        sa.Column("provider", sa.String(length=32), nullable=False, server_default="yookassa"),
        sa.Column("provider_payment_id", sa.String(length=128), nullable=False, server_default=""),
        sa.Column("status", sa.String(length=32), nullable=False, server_default="pending"),
        sa.Column("amount_minor", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("currency", sa.String(length=8), nullable=False, server_default="RUB"),
        sa.Column("idempotence_key", sa.String(length=128), nullable=False),
        sa.Column("return_url", sa.String(length=500), nullable=False, server_default=""),
        sa.Column("confirmation_url", sa.String(length=1000), nullable=False, server_default=""),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            nullable=False,
            server_default=sa.text("CURRENT_TIMESTAMP"),
        ),
        sa.Column("metadata_json", sa.JSON(), nullable=False, server_default=sa.text("'{}'::json")),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("idempotence_key"),
    )
    op.create_index(op.f("ix_billing_orders_plan_code"), "billing_orders", ["plan_code"], unique=False)
    op.create_index(
        op.f("ix_billing_orders_provider_payment_id"),
        "billing_orders",
        ["provider_payment_id"],
        unique=False,
    )
    op.alter_column("billing_orders", "kind", server_default=None)
    op.alter_column("billing_orders", "provider", server_default=None)
    op.alter_column("billing_orders", "provider_payment_id", server_default=None)
    op.alter_column("billing_orders", "status", server_default=None)
    op.alter_column("billing_orders", "amount_minor", server_default=None)
    op.alter_column("billing_orders", "currency", server_default=None)
    op.alter_column("billing_orders", "return_url", server_default=None)
    op.alter_column("billing_orders", "confirmation_url", server_default=None)
    op.alter_column("billing_orders", "created_at", server_default=None)
    op.alter_column("billing_orders", "updated_at", server_default=None)
    op.alter_column("billing_orders", "metadata_json", server_default=None)

    op.add_column(
        "payment_events",
        sa.Column("provider_event_id", sa.String(length=160), nullable=False, server_default=""),
    )
    op.create_index(op.f("ix_payment_events_provider_event_id"), "payment_events", ["provider_event_id"], unique=False)
    op.alter_column("payment_events", "provider_event_id", server_default=None)


def downgrade() -> None:
    op.drop_index(op.f("ix_payment_events_provider_event_id"), table_name="payment_events")
    op.drop_column("payment_events", "provider_event_id")

    op.drop_index(op.f("ix_billing_orders_provider_payment_id"), table_name="billing_orders")
    op.drop_index(op.f("ix_billing_orders_plan_code"), table_name="billing_orders")
    op.drop_table("billing_orders")
    op.drop_table("billing_wallets")

    op.drop_column("billing_subscriptions", "updated_at")
    op.drop_column("billing_subscriptions", "created_at")
    op.drop_column("billing_subscriptions", "last_failure_code")
    op.drop_column("billing_subscriptions", "last_payment_id")
    op.drop_column("billing_subscriptions", "retry_count")
    op.drop_column("billing_subscriptions", "cancel_at_period_end")
    op.drop_column("billing_subscriptions", "next_charge_at")
    op.drop_column("billing_subscriptions", "current_period_end_at")
    op.drop_column("billing_subscriptions", "current_period_start_at")
    op.drop_column("billing_subscriptions", "payment_method_id")
    op.drop_column("billing_subscriptions", "provider_subscription_ref")
    op.drop_column("billing_subscriptions", "provider")

    op.drop_column("billing_plans", "updated_at")
    op.drop_column("billing_plans", "created_at")
    op.drop_column("billing_plans", "sort_order")
    op.drop_column("billing_plans", "fair_use_limit")
    op.drop_column("billing_plans", "monthly_quota")
    op.drop_column("billing_plans", "token_grant")
    op.drop_column("billing_plans", "is_active")
    op.drop_column("billing_plans", "sale_ends_at")
    op.drop_column("billing_plans", "sale_starts_at")
    op.drop_column("billing_plans", "sale_percent")
    op.drop_column("billing_plans", "sale_badge_text")
    op.drop_column("billing_plans", "sale_price_minor")
    op.drop_column("billing_plans", "base_price_minor")
    op.drop_column("billing_plans", "currency")
    op.drop_column("billing_plans", "description")
    op.drop_column("billing_plans", "kind")

    op.drop_column("billing_customers", "created_at")
