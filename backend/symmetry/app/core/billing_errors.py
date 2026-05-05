class BillingError(Exception):
    pass


class InsufficientTokensError(BillingError):
    def __init__(self, user_id: str, required: int, available: int) -> None:
        self.user_id = user_id
        self.required = required
        self.available = available
        super().__init__(
            f"insufficient_tokens: user={user_id} required={required} available={available}"
        )


class PlanNotFoundError(BillingError):
    def __init__(self, plan_code: str) -> None:
        self.plan_code = plan_code
        super().__init__(f"plan_not_found: {plan_code}")


class CheckoutFailedError(BillingError):
    def __init__(self, plan_code: str, reason: str) -> None:
        self.plan_code = plan_code
        self.reason = reason
        super().__init__(f"checkout_failed: {plan_code} reason={reason}")


class WebhookSignatureError(BillingError):
    pass


class WelcomeAlreadyClaimedError(BillingError):
    def __init__(self, user_id: str) -> None:
        self.user_id = user_id
        super().__init__(f"welcome_already_claimed: {user_id}")


class SubscriptionRenewalError(BillingError):
    def __init__(self, subscription_id: str, reason: str) -> None:
        self.subscription_id = subscription_id
        self.reason = reason
        super().__init__(f"renewal_failed: {subscription_id} reason={reason}")
