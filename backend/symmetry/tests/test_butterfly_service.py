from types import SimpleNamespace

from app.services.butterfly import ButterflyService


def test_default_entities_only_seed_generated_location():
    service = ButterflyService()

    short_entities = service.default_entities_for_mode(
        mode="shortStory",
        language="ru",
        location="Тихая гавань",
    )
    long_entities = service.default_entities_for_mode(
        mode="longCampaign",
        language="en",
        location="Ash Harbor",
    )

    assert short_entities == [
        {
            "slug": service.slugify("Тихая гавань"),
            "title": "Тихая гавань",
            "entity_kind": "location",
        }
    ]
    assert long_entities == [
        {
            "slug": "ash-harbor",
            "title": "Ash Harbor",
            "entity_kind": "location",
        }
    ]


def test_normalize_impact_seeds_clamps_short_story_payload():
    service = ButterflyService()

    normalized = service.normalize_impact_seeds(
        [
            {
                "entity_kind": "company",
                "entity_slug": "North Harbor Trade",
                "impact_type": "scarcity",
                "strength": 9,
                "delay_min_turns": 0,
                "delay_max_turns": 9,
                "visibility": "hidden",
                "summary": "A long supply crisis starts brewing",
            },
            {
                "entity_kind": "company",
                "entity_slug": "north-harbor-trade",
                "impact_type": "scarcity",
                "strength": 1,
                "delay_min_turns": 1,
                "delay_max_turns": 1,
                "visibility": "public",
                "summary": "duplicate should be ignored",
            },
            {
                "entity_kind": "faction",
                "entity_slug": "civic-watch",
                "impact_type": "alertness",
                "strength": 2,
                "delay_min_turns": 1,
                "delay_max_turns": 2,
                "visibility": "public",
                "summary": "The watch pays closer attention",
            },
            {
                "entity_kind": "market",
                "entity_slug": "shadow-market",
                "impact_type": "opportunity",
                "strength": 2,
                "delay_min_turns": 1,
                "delay_max_turns": 2,
                "visibility": "public",
                "summary": "This one should be cut off by the short-story limit",
            },
        ],
        mode="shortStory",
        current_location="Quiet Harbor",
    )

    assert len(normalized) == 2
    assert normalized[0]["entity_slug"] == "north-harbor-trade"
    assert normalized[0]["strength"] == 2
    assert normalized[0]["delay_min_turns"] == 1
    assert normalized[0]["delay_max_turns"] == 2


def test_fallback_seed_targets_location_in_both_modes():
    service = ButterflyService()

    short_seed = service.fallback_seed_from_turn(
        mode="shortStory",
        importance=5,
        summary="A suspicious rumor starts spreading",
        current_location="Quiet Harbor",
    )
    long_seed = service.fallback_seed_from_turn(
        mode="longCampaign",
        importance=8,
        summary="Smugglers keep a route alive",
        current_location="Ash Harbor",
    )

    assert short_seed[0]["entity_kind"] == "location"
    assert short_seed[0]["visibility"] == "public"
    assert long_seed[0]["entity_kind"] == "location"
    assert long_seed[0]["visibility"] == "hidden"


def test_apply_immediate_world_patch_merges_nested_global_vars():
    service = ButterflyService()
    world_state = SimpleNamespace(
        global_vars={
            "weather": "clear",
            "prices": {"local-guild": 1},
        }
    )

    service.apply_immediate_world_patch(
        world_state,
        global_vars_patch={
            "prices": {"local-guild": 3, "shadow-market": -1},
            "weather": "fog",
        },
    )

    assert world_state.global_vars["weather"] == "fog"
    assert world_state.global_vars["prices"]["local-guild"] == 3
    assert world_state.global_vars["prices"]["shadow-market"] == -1
