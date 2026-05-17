"""Phase 0.1 — DeepSeek choices structured output test.

Отправляет 10 запросов к DeepSeek с разными контекстами (бой, диалог, исследование)
и проверяет стабильность генерации choices в JSON.

Запуск: cd backend/symmetry && python tests/test_deepseek_choices.py
"""

import asyncio
import json
import os
import sys
import time

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import httpx
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

from app.services.ai_gateway import (
    TURN_SCHEMA_PROMPT,
    build_turn_system_prompt,
    build_turn_prefix_messages,
    build_turn_dynamic_payload,
    build_messages,
    normalize_prompt_text,
    _parse_usage,
    _extract_finish_reason,
)

BASE_URL = os.getenv("SYMMETRY_SERVER_LLM_BASE_URL", "https://api.deepseek.com/v1")
API_KEY = os.getenv("SYMMETRY_SERVER_LLM_API_KEY", "")
MODEL = os.getenv("SYMMETRY_SERVER_LLM_MODEL", "deepseek-v4-flash")
TIMEOUT = int(os.getenv("SYMMETRY_SERVER_LLM_TIMEOUT_SECONDS", "60"))

SCENARIOS = [
    {
        "name": "combat_ambush",
        "setting": "grimdarkFantasy",
        "language": "ru",
        "location": "Перевал Мёртвых",
        "objective": "Пережить засаду бандитов",
        "player_action": "Я выхватываю меч и атакую ближайшего бандита",
    },
    {
        "name": "combat_boss",
        "setting": "litRpgProgression",
        "language": "ru",
        "location": "Глубины Подземелья",
        "objective": "Победить босса подземелья",
        "player_action": "Я использую огненный шар против каменного голема",
    },
    {
        "name": "combat_defense",
        "setting": "postApocalypse",
        "language": "ru",
        "location": "Заброшенный Бункер",
        "objective": "Защитить убежище от мутантов",
        "player_action": "Я стреляю из дробовика в ближайшего мутанта",
    },
    {
        "name": "dialogue_negotiation",
        "setting": "nearFutureSciFi",
        "language": "ru",
        "location": "Космическая Станция «Омега»",
        "objective": "Договориться с контрабандистом о цене",
        "player_action": "Я предлагаю контрабандисту сделку: информация в обмен на проход",
    },
    {
        "name": "dialogue_interrogation",
        "setting": "horrorWeird",
        "language": "ru",
        "location": "Допросная в Участке",
        "objective": "Выведать у пленного где логово культа",
        "player_action": "Я спрашиваю пленного о местонахождении алтаря, глядя ему в глаза",
    },
    {
        "name": "dialogue_persuasion",
        "setting": "romantasy",
        "language": "en",
        "location": "Elven Court of Thorns",
        "objective": "Convince the elven queen to join the alliance",
        "player_action": "I kneel and present the ancient treaty, appealing to the queen's honor",
    },
    {
        "name": "exploration_search",
        "setting": "cozyFantasy",
        "language": "ru",
        "location": "Зачарованный Лес",
        "objective": "Найти редкий ингредиент для зелья",
        "player_action": "Я осматриваю поляну в поисках светящихся грибов",
    },
    {
        "name": "exploration_discovery",
        "setting": "grimdarkFantasy",
        "language": "ru",
        "location": "Забытые Катакомбы",
        "objective": "Исследовать древние руины",
        "player_action": "Я зажигаю факел и вхожу в тёмный коридор",
    },
    {
        "name": "exploration_travel",
        "setting": "postApocalypse",
        "language": "en",
        "location": "Wasteland Highway",
        "objective": "Reach the next settlement before nightfall",
        "player_action": "I follow the old highway, scanning the horizon for raiders",
    },
    {
        "name": "social_mystery",
        "setting": "romantasy",
        "language": "ru",
        "location": "Королевский Бал",
        "objective": "Выяснить кто из гостей — шпион",
        "player_action": "Я танцую с графиней и осторожно расспрашиваю её о гостях",
    },
]


def build_test_context(scenario: dict) -> dict:
    """Строит контекст похожий на тот, что создаёт campaign_runtime.build_turn_context."""
    lang = scenario["language"]
    return {
        "campaign_bootstrap": {
            "title": "Тестовая Кампания",
            "setting": scenario["setting"],
            "mode": "shortStory",
            "difficulty": "normal",
            "language": lang,
            "story_prompt": f"Ты — герой в мире {scenario['setting']}.",
        },
        "world_bootstrap": {
            "starting_location": scenario["location"],
            "starting_objective": scenario["objective"],
        },
        "character_brief": {
            "character": {"prompt_fragment": "Опытный искатель приключений"},
            "character_prompt": "Герой-одиночка с тёмным прошлым",
        },
        "dynamic_context": {
            "turn_number": 3,
            "memory": {
                "recent_turns": [],
                "key_facts": [],
                "known_characters": [],
            },
            "world_state": {
                "current_day": 1,
                "minute_of_day": 480,
                "butterfly": {},
                "weather": "ясно",
                "factions": {},
                "prices": {},
            },
            "state": {
                "location": scenario["location"],
                "objective": scenario["objective"],
                "choices": [],
                "active_modules": ["vitality"],
                "character": {"hp": 10, "max_hp": 12, "energy": 4, "max_energy": 6},
            },
            "request": {"trigger_source": "player_input"},
            "relevant_chronicles": [],
        },
    }


def validate_choices(choices: list, scenario_name: str) -> tuple:
    """Валидирует поле choices. Возвращает (issues, format_type)."""
    issues = []
    fmt = "unknown"
    if choices is None:
        issues.append("choices is None")
        return issues, fmt
    if not isinstance(choices, list):
        issues.append("choices is not a list: " + type(choices).__name__)
        return issues, fmt

    count = len(choices)
    if count < 1:
        issues.append("choices is empty (min 1 expected)")
        return issues, fmt
    if count > 5:
        issues.append("too many choices: " + str(count) + " (max 5 expected)")

    str_count = sum(1 for c in choices if isinstance(c, str))
    dict_count = sum(1 for c in choices if isinstance(c, dict))

    if str_count == count:
        fmt = "strings"
        for i, c in enumerate(choices):
            if not c.strip():
                issues.append("choice[" + str(i) + "] is empty string")
            elif len(c) > 120:
                issues.append("choice[" + str(i) + "] too long (" + str(len(c)) + " chars): " + c[:60] + "...")
    elif dict_count == count:
        fmt = "objects"
        for i, c in enumerate(choices):
            label = c.get("label", "")
            if not label or not isinstance(label, str):
                issues.append("choice[" + str(i) + "].label missing or not string: " + repr(label))
            elif len(label) > 120:
                issues.append("choice[" + str(i) + "].label too long (" + str(len(label)) + " chars): " + label[:60] + "...")
            cid = c.get("id", "")
            if not cid or not isinstance(cid, str):
                issues.append("choice[" + str(i) + "].id missing or not string: " + repr(cid))
    else:
        fmt = "mixed"
        for i, c in enumerate(choices):
            if isinstance(c, str):
                if not c.strip():
                    issues.append("choice[" + str(i) + "] (str) is empty")
            elif isinstance(c, dict):
                if not c.get("label", ""):
                    issues.append("choice[" + str(i) + "] (dict) has no label")
            else:
                issues.append("choice[" + str(i) + "] unexpected type: " + type(c).__name__)

    return issues, fmt


async def run_test():
    print("=" * 70)
    print("Phase 0.1 -- DeepSeek Choices Structured Output Test")
    print("Model: " + MODEL)
    print("Base URL: " + BASE_URL)
    print("Scenarios: " + str(len(SCENARIOS)))
    print("=" * 70)

    client = httpx.AsyncClient(timeout=httpx.Timeout(TIMEOUT))
    results = []
    success_count = 0
    fail_count = 0

    try:
        for idx, scenario in enumerate(SCENARIOS):
            name = scenario["name"]
            print("\n--- Test " + str(idx + 1) + "/" + str(len(SCENARIOS)) + ": " + name + " ---")

            context = build_test_context(scenario)
            system_prompt = build_turn_system_prompt(
                language=scenario["language"],
                mode="shortStory",
                turn_number=3,
                trigger_source="player_input",
            )
            prefix_messages = build_turn_prefix_messages(
                system_prompt=system_prompt,
                context=context,
            )
            dynamic_payload = build_turn_dynamic_payload(
                context=context,
                player_action=scenario["player_action"],
                trigger_source="player_input",
            )
            messages = build_messages(
                prefix_messages=prefix_messages,
                dynamic_payload=dynamic_payload,
            )

            payload = {
                "model": MODEL,
                "messages": messages,
                "temperature": 0.8,
                "response_format": {"type": "json_object"},
                "max_tokens": 1024,
            }
            if MODEL.startswith("deepseek-v4-"):
                payload["thinking"] = {"type": "disabled"}

            t0 = time.monotonic()
            try:
                response = await client.post(
                    BASE_URL.rstrip("/") + "/chat/completions",
                    headers={
                        "Authorization": "Bearer " + API_KEY,
                        "Content-Type": "application/json",
                    },
                    json=payload,
                )
                response.raise_for_status()
                data = response.json()
                if not isinstance(data, dict):
                    raise ValueError("API returned non-dict: " + type(data).__name__)

                usage = _parse_usage(data.get("usage"))
                finish_reason = _extract_finish_reason(data)

                choices_list = data.get("choices", [])
                if not isinstance(choices_list, list) or not choices_list:
                    raise ValueError("choices list empty or not a list: " + type(choices_list).__name__)
                first_choice = choices_list[0]
                if not isinstance(first_choice, dict):
                    raise ValueError("first choice is not dict: " + type(first_choice).__name__)
                message = first_choice.get("message", {})
                if not isinstance(message, dict):
                    raise ValueError("message is not dict: " + type(message).__name__)
                content = message.get("content", "")

                try:
                    parsed = json.loads(content)
                except json.JSONDecodeError:
                    import re
                    match = re.search(r"\{.*\}", content, flags=re.DOTALL)
                    parsed = json.loads(match.group(0)) if match else {}

                choices = parsed.get("choices", [])
                narration = parsed.get("narration", "")
                issues, fmt = validate_choices(choices, name)

                latency = time.monotonic() - t0

                choice_labels = []
                if isinstance(choices, list):
                    for c in choices:
                        if isinstance(c, dict):
                            choice_labels.append(str(c.get("label", c.get("id", "")))[:60])
                        elif isinstance(c, str):
                            choice_labels.append(c[:60])
                        else:
                            choice_labels.append(str(c)[:60])

                result = {
                    "scenario": name,
                    "success": len(issues) == 0,
                    "choices_count": len(choices) if isinstance(choices, list) else 0,
                    "choices_format": fmt,
                    "issues": issues,
                    "latency_s": round(latency, 2),
                    "completion_tokens": usage.completion_tokens,
                    "total_tokens": usage.total_tokens,
                    "finish_reason": finish_reason,
                    "narration_preview": narration[:120] if narration else "(empty)",
                    "choices_labels": choice_labels,
                }

                if result["success"]:
                    success_count += 1
                    print("  OK: " + str(len(choices)) + " choices (" + fmt + "), " + str(round(latency, 1)) + "s, " + str(usage.completion_tokens) + " tokens")
                    for i, lbl in enumerate(result["choices_labels"]):
                        print("    [" + str(i) + "] " + lbl)
                else:
                    fail_count += 1
                    print("  FAIL: " + str(issues))
            except Exception as e:
                import traceback
                print("  TRACEBACK: " + traceback.format_exc())
                latency = time.monotonic() - t0
                result = {
                    "scenario": name,
                    "success": False,
                    "choices_count": 0,
                    "choices_format": "error",
                    "issues": ["API error: " + str(e)],
                    "latency_s": round(latency, 2),
                    "completion_tokens": 0,
                    "total_tokens": 0,
                    "finish_reason": "error",
                    "narration_preview": "",
                    "choices_labels": [],
                }
                fail_count += 1
                print("  ERROR: " + str(e))

            results.append(result)
            if idx < len(SCENARIOS) - 1:
                await asyncio.sleep(0.5)

    finally:
        await client.aclose()

    return results, success_count, fail_count


def write_report(results, success_count, fail_count):
    report_path = os.path.join(
        os.path.dirname(__file__), "..", "..", "..",
        "docs", "features", "game-systems", "deepseek-choices-test.md",
    )
    os.makedirs(os.path.dirname(report_path), exist_ok=True)

    formats = {}
    for r in results:
        fmt = r.get("choices_format", "unknown")
        formats[fmt] = formats.get(fmt, 0) + 1
    format_parts = []
    for k, v in sorted(formats.items()):
        format_parts.append(k + ": " + str(v))
    format_summary = ", ".join(format_parts)

    avg_choices = sum(r["choices_count"] for r in results) / max(len(results), 1)
    avg_latency = sum(r["latency_s"] for r in results) / max(len(results), 1)
    avg_tokens = sum(r["total_tokens"] for r in results) // max(len(results), 1)

    lines = [
        "# DeepSeek Choices Structured Output Test",
        "",
        "Date: " + time.strftime("%Y-%m-%d"),
        "Model: " + MODEL,
        "Base URL: " + BASE_URL,
        "Scenarios tested: " + str(len(results)),
        "",
        "## Summary",
        "",
        "- **Success:** " + str(success_count) + "/" + str(len(results)) + " (" + str(100 * success_count // max(len(results), 1)) + "%)",
        "- **Failed:** " + str(fail_count) + "/" + str(len(results)),
        "- **Average choices:** " + str(round(avg_choices, 1)),
        "- **Average latency:** " + str(round(avg_latency, 1)) + "s",
        "- **Average tokens:** " + str(avg_tokens),
        "- **Formats:** " + format_summary,
        "",
        "## Detailed Results",
        "",
    ]

    for r in results:
        status = "PASS" if r["success"] else "FAIL"
        lines.append("### " + r["scenario"] + " -- " + status)
        lines.append("")
        lines.append("- Choices: " + str(r["choices_count"]) + " (format: " + r.get("choices_format", "unknown") + ")")
        lines.append("- Latency: " + str(r["latency_s"]) + "s")
        lines.append("- Tokens: " + str(r["completion_tokens"]) + " completion / " + str(r["total_tokens"]) + " total")
        lines.append("- Finish: " + str(r["finish_reason"]))
        lines.append("- Narration: " + str(r["narration_preview"]))
        if r["choices_labels"]:
            lines.append("- Labels:")
            for lbl in r["choices_labels"]:
                lines.append("  - " + lbl)
        if r["issues"]:
            lines.append("- Issues:")
            for issue in r["issues"]:
                lines.append("  - " + issue)
        lines.append("")

    lines += [
        "## Conclusion",
        "",
    ]
    if fail_count == 0:
        lines += [
            "DeepSeek стабильно генерирует structured choices (" + str(success_count) + "/" + str(len(results)) + ").",
            "Можно переходить к Phase 0.2 -- Choices JSON contract.",
            "",
            "**Важно:** формат choices -- " + format_summary + ". В Phase 0.2 нужно обновить системный промпт",
            "чтобы модель возвращала объекты {id, label, hint, tag} вместо строк.",
        ]
    elif fail_count <= 2:
        lines += [
            "DeepSeek генерирует choices в большинстве случаев (" + str(success_count) + "/" + str(len(results)) + ").",
            str(fail_count) + " отказа -- требуются fallback-механизмы (парсинг текста при ошибке JSON).",
            "Рекомендация: продолжить с планом, добавив fallback в Phase 0.2.",
        ]
    else:
        lines += [
            "DeepSeek НЕ справляется с генерацией choices (" + str(success_count) + "/" + str(len(results)) + " успешных).",
            "Нужно менять подход: либо парсинг текста, либо статические choices.",
            "РЕКОМЕНДАЦИЯ: НЕ продолжать Phase 0.2 до решения этой проблемы.",
        ]

    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

    print("\nReport written to: " + report_path)
    return report_path


if __name__ == "__main__":
    results, ok, fail = asyncio.run(run_test())
    write_report(results, ok, fail)
    if fail > len(results) // 2:
        print("\n*** GATE FAILED: DeepSeek choices generation not reliable enough ***")
        sys.exit(1)
    else:
        print("\n*** GATE PASSED: " + str(ok) + "/" + str(len(results)) + " scenarios OK ***")
