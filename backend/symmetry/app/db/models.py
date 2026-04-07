from datetime import UTC, datetime

from pgvector.sqlalchemy import Vector
from sqlalchemy import (
    JSON,
    Boolean,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


def utcnow() -> datetime:
    return datetime.now(UTC)


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    email: Mapped[str] = mapped_column(String(320), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(255))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    profile: Mapped["UserProfile"] = relationship(back_populates="user", uselist=False)
    identities: Mapped[list["AuthIdentity"]] = relationship(back_populates="user")
    sessions: Mapped[list["AuthSession"]] = relationship(back_populates="user")


class UserProfile(Base):
    __tablename__ = "user_profiles"

    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    display_name: Mapped[str] = mapped_column(String(120), default="")
    avatar_url: Mapped[str] = mapped_column(String(500), default="")
    preferences: Mapped[dict] = mapped_column(JSONB, default=dict)

    user: Mapped[User] = relationship(back_populates="profile")


class AuthIdentity(Base):
    __tablename__ = "auth_identities"
    __table_args__ = (
        UniqueConstraint("provider", "provider_user_id", name="uq_auth_identity_provider"),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    provider: Mapped[str] = mapped_column(String(50))
    provider_user_id: Mapped[str] = mapped_column(String(255))
    provider_email: Mapped[str] = mapped_column(String(320), default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)

    user: Mapped[User] = relationship(back_populates="identities")


class AuthSession(Base):
    __tablename__ = "auth_sessions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    refresh_token_hash: Mapped[str] = mapped_column(String(128), unique=True, index=True)
    user_agent: Mapped[str] = mapped_column(String(500), default="")
    ip_address: Mapped[str] = mapped_column(String(64), default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    user: Mapped[User] = relationship(back_populates="sessions")


class Campaign(Base):
    __tablename__ = "campaigns"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    owner_user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    title: Mapped[str] = mapped_column(String(255))
    setting: Mapped[str] = mapped_column(String(100))
    mode: Mapped[str] = mapped_column(String(50))
    difficulty: Mapped[str] = mapped_column(String(50))
    language: Mapped[str] = mapped_column(String(8), default="ru")
    status: Mapped[str] = mapped_column(String(32), default="active")
    current_snapshot_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("campaign_snapshots.id", ondelete="SET NULL"), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class CampaignMember(Base):
    __tablename__ = "campaign_members"
    __table_args__ = (UniqueConstraint("campaign_id", "user_id", name="uq_campaign_member"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    campaign_id: Mapped[str] = mapped_column(String(36), ForeignKey("campaigns.id", ondelete="CASCADE"))
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    role: Mapped[str] = mapped_column(String(32), default="owner")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class CampaignSnapshot(Base):
    __tablename__ = "campaign_snapshots"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    campaign_id: Mapped[str] = mapped_column(String(36), ForeignKey("campaigns.id", ondelete="CASCADE"))
    version: Mapped[int] = mapped_column(Integer, default=1)
    state_json: Mapped[dict] = mapped_column(JSONB)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class CampaignTurn(Base):
    __tablename__ = "campaign_turns"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    campaign_id: Mapped[str] = mapped_column(String(36), ForeignKey("campaigns.id", ondelete="CASCADE"))
    snapshot_id: Mapped[str] = mapped_column(String(36), ForeignKey("campaign_snapshots.id", ondelete="CASCADE"))
    turn_number: Mapped[int] = mapped_column(Integer)
    player_action: Mapped[str] = mapped_column(Text)
    llm_response_json: Mapped[dict] = mapped_column(JSONB)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class WorldState(Base):
    __tablename__ = "world_state"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    campaign_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("campaigns.id", ondelete="CASCADE"), unique=True
    )
    current_day: Mapped[int] = mapped_column(Integer, default=1)
    minute_of_day: Mapped[int] = mapped_column(Integer, default=480)
    global_vars: Mapped[dict] = mapped_column(JSONB, default=dict)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class WorldLocation(Base):
    __tablename__ = "world_locations"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    campaign_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("campaigns.id", ondelete="CASCADE"), nullable=True
    )
    slug: Mapped[str] = mapped_column(String(120), index=True)
    title: Mapped[str] = mapped_column(String(255))
    metadata_json: Mapped[dict] = mapped_column(JSONB, default=dict)


class WorldFaction(Base):
    __tablename__ = "world_factions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    campaign_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("campaigns.id", ondelete="CASCADE"), nullable=True
    )
    slug: Mapped[str] = mapped_column(String(120), index=True)
    title: Mapped[str] = mapped_column(String(255))
    metadata_json: Mapped[dict] = mapped_column(JSONB, default=dict)


class WorldEntity(Base):
    __tablename__ = "world_entities"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    campaign_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("campaigns.id", ondelete="CASCADE"), index=True
    )
    slug: Mapped[str] = mapped_column(String(120), index=True)
    title: Mapped[str] = mapped_column(String(255))
    entity_kind: Mapped[str] = mapped_column(String(64), default="world")
    status: Mapped[str] = mapped_column(String(32), default="active")
    influence: Mapped[int] = mapped_column(Integer, default=0)
    metadata_json: Mapped[dict] = mapped_column(JSONB, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class WorldChronicle(Base):
    __tablename__ = "world_chronicles"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    campaign_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("campaigns.id", ondelete="CASCADE"), nullable=True, index=True
    )
    location_slug: Mapped[str] = mapped_column(String(120), index=True, default="")
    entity_type: Mapped[str] = mapped_column(String(64), default="event")
    event_text: Mapped[str] = mapped_column(Text)
    importance: Mapped[int] = mapped_column(Integer, default=5)
    tags: Mapped[list] = mapped_column(JSONB, default=list)
    metadata_json: Mapped[dict] = mapped_column(JSONB, default=dict)
    vector: Mapped[list[float] | None] = mapped_column(Vector(768), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class SimulationTick(Base):
    __tablename__ = "simulation_ticks"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    campaign_id: Mapped[str] = mapped_column(String(36), ForeignKey("campaigns.id", ondelete="CASCADE"))
    from_day: Mapped[int] = mapped_column(Integer)
    from_minute: Mapped[int] = mapped_column(Integer)
    to_day: Mapped[int] = mapped_column(Integer)
    to_minute: Mapped[int] = mapped_column(Integer)
    delta_minutes: Mapped[int] = mapped_column(Integer)
    metadata_json: Mapped[dict] = mapped_column(JSONB, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class SimulationJob(Base):
    __tablename__ = "simulation_jobs"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    campaign_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("campaigns.id", ondelete="CASCADE"), index=True
    )
    job_type: Mapped[str] = mapped_column(String(64), default="expand_consequences")
    status: Mapped[str] = mapped_column(String(32), default="pending", index=True)
    payload_json: Mapped[dict] = mapped_column(JSONB, default=dict)
    attempts: Mapped[int] = mapped_column(Integer, default=0)
    last_error: Mapped[str] = mapped_column(Text, default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    available_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    started_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    finished_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class PendingConsequence(Base):
    __tablename__ = "pending_consequences"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    campaign_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("campaigns.id", ondelete="CASCADE"), index=True
    )
    source_turn_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("campaign_turns.id", ondelete="SET NULL"), nullable=True
    )
    source_snapshot_version: Mapped[int] = mapped_column(Integer, default=0)
    mode: Mapped[str] = mapped_column(String(50), default="shortStory")
    status: Mapped[str] = mapped_column(String(32), default="pending", index=True)
    due_turn_number: Mapped[int] = mapped_column(Integer, default=1)
    entity_kind: Mapped[str] = mapped_column(String(64), default="world")
    entity_slug: Mapped[str] = mapped_column(String(120), default="", index=True)
    effect_type: Mapped[str] = mapped_column(String(64), default="rumor")
    strength: Mapped[int] = mapped_column(Integer, default=1)
    visibility: Mapped[str] = mapped_column(String(16), default="hidden")
    summary: Mapped[str] = mapped_column(Text, default="")
    payload_json: Mapped[dict] = mapped_column(JSONB, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    resolved_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class StoryTemplate(Base):
    __tablename__ = "story_templates"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    author_user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    title: Mapped[str] = mapped_column(String(255))
    summary: Mapped[str] = mapped_column(Text, default="")
    prompt_text: Mapped[str] = mapped_column(Text)
    setting: Mapped[str] = mapped_column(String(100), default="")
    is_public: Mapped[bool] = mapped_column(Boolean, default=False)
    metadata_json: Mapped[dict] = mapped_column(JSONB, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class StoryTemplateTag(Base):
    __tablename__ = "story_template_tags"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    slug: Mapped[str] = mapped_column(String(80), unique=True, index=True)
    title: Mapped[str] = mapped_column(String(80))


class StoryTemplateTagLink(Base):
    __tablename__ = "story_template_tag_links"
    __table_args__ = (
        UniqueConstraint("story_template_id", "tag_id", name="uq_story_template_tag"),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    story_template_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("story_templates.id", ondelete="CASCADE")
    )
    tag_id: Mapped[str] = mapped_column(String(36), ForeignKey("story_template_tags.id", ondelete="CASCADE"))


class StoryTemplateLike(Base):
    __tablename__ = "story_template_likes"
    __table_args__ = (
        UniqueConstraint("story_template_id", "user_id", name="uq_story_template_like"),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    story_template_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("story_templates.id", ondelete="CASCADE")
    )
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class StoryTemplateView(Base):
    __tablename__ = "story_template_views"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    story_template_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("story_templates.id", ondelete="CASCADE")
    )
    user_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class StoryTemplateBookmark(Base):
    __tablename__ = "story_template_bookmarks"
    __table_args__ = (
        UniqueConstraint(
            "story_template_id",
            "user_id",
            name="uq_story_template_bookmark",
        ),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    story_template_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("story_templates.id", ondelete="CASCADE")
    )
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class BillingCustomer(Base):
    __tablename__ = "billing_customers"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("users.id", ondelete="CASCADE"), unique=True
    )
    metadata_json: Mapped[dict] = mapped_column(JSON, default=dict)


class BillingPlan(Base):
    __tablename__ = "billing_plans"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    code: Mapped[str] = mapped_column(String(80), unique=True)
    title: Mapped[str] = mapped_column(String(120))
    metadata_json: Mapped[dict] = mapped_column(JSON, default=dict)


class BillingSubscription(Base):
    __tablename__ = "billing_subscriptions"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    billing_customer_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("billing_customers.id", ondelete="CASCADE")
    )
    billing_plan_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("billing_plans.id", ondelete="CASCADE")
    )
    status: Mapped[str] = mapped_column(String(32), default="draft")
    metadata_json: Mapped[dict] = mapped_column(JSON, default=dict)


class CreditLedger(Base):
    __tablename__ = "credit_ledger"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"))
    amount: Mapped[int] = mapped_column(Integer)
    reason: Mapped[str] = mapped_column(String(255))
    metadata_json: Mapped[dict] = mapped_column(JSON, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)


class PaymentEvent(Base):
    __tablename__ = "payment_events"

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    billing_customer_id: Mapped[str | None] = mapped_column(
        String(36), ForeignKey("billing_customers.id", ondelete="SET NULL"), nullable=True
    )
    provider: Mapped[str] = mapped_column(String(80))
    event_type: Mapped[str] = mapped_column(String(120))
    payload_json: Mapped[dict] = mapped_column(JSON, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=utcnow)
