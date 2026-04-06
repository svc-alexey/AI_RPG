from app.db.models import SimulationTick, WorldState
from app.services.ids import new_id


class SimulationService:
    TURN_MINUTES = 10

    def advance(self, world_state: WorldState) -> tuple[WorldState, SimulationTick]:
        from_day = world_state.current_day
        from_minute = world_state.minute_of_day
        total_minutes = from_minute + self.TURN_MINUTES
        day_increment, minute_of_day = divmod(total_minutes, 24 * 60)
        world_state.current_day = from_day + day_increment
        world_state.minute_of_day = minute_of_day
        tick = SimulationTick(
            id=new_id(),
            campaign_id=world_state.campaign_id,
            from_day=from_day,
            from_minute=from_minute,
            to_day=world_state.current_day,
            to_minute=world_state.minute_of_day,
            delta_minutes=self.TURN_MINUTES,
            metadata_json={"reason": "turn_processed"},
        )
        return world_state, tick
