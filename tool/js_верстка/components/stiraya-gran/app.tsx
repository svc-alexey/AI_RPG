"use client";

import { useState } from "react";
import { HomeScreen } from "./screens/home-screen";
import { SavedCampaignsScreen } from "./screens/saved-campaigns-screen";
import { NewCampaignScreen } from "./screens/new-campaign-screen";
import { GameScreen } from "./screens/game-screen";
import { SettingsScreen } from "./screens/settings-screen";

type Screen = "home" | "saved" | "new-campaign" | "game" | "settings";

// Mock data for saved campaigns
const MOCK_CAMPAIGNS = [
  {
    id: "1",
    name: "Тайны Росариума",
    character: "Лёха — Мастер фонариков",
    genre: "Уютное фэнтези",
    lastPlayed: "2 часа назад",
    turn: 12,
  },
  {
    id: "2",
    name: "Кровь и Сталь",
    character: "Рейна — Наёмница",
    genre: "Тёмное фэнтези",
    lastPlayed: "Вчера",
    turn: 45,
  },
];

export function StirayaGranApp() {
  const [currentScreen, setCurrentScreen] = useState<Screen>("home");

  const handleNavigate = (screen: string) => {
    setCurrentScreen(screen as Screen);
  };

  return (
    <>
      {currentScreen === "home" && (
        <HomeScreen onNavigate={handleNavigate} />
      )}
      {currentScreen === "saved" && (
        <SavedCampaignsScreen 
          onNavigate={handleNavigate} 
          campaigns={MOCK_CAMPAIGNS}
        />
      )}
      {currentScreen === "new-campaign" && (
        <NewCampaignScreen onNavigate={handleNavigate} />
      )}
      {currentScreen === "game" && (
        <GameScreen onNavigate={handleNavigate} />
      )}
      {currentScreen === "settings" && (
        <SettingsScreen onNavigate={handleNavigate} />
      )}
    </>
  );
}
