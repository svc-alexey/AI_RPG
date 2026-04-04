"use client";

import { useState } from "react";
import { ArrowLeft, ArrowRight, Check, Shuffle, Sparkles, Zap } from "lucide-react";
import { cn } from "@/lib/utils";

interface NewCampaignScreenProps {
  onNavigate: (screen: string) => void;
}

const GENRES = [
  { id: "romantika", label: "Романтика" },
  { id: "romantasy", label: "Romantasy" },
  { id: "fantasy", label: "Фэнтези" },
  { id: "thriller", label: "Триллер" },
  { id: "detective", label: "Детектив" },
  { id: "horror", label: "Хоррор" },
  { id: "ya", label: "Young Adult" },
  { id: "speculative", label: "Sci-Fi" },
  { id: "dark-academia", label: "Dark academia" },
  { id: "cozy", label: "Cozy" },
];

const SETTINGS = [
  { id: "medieval", label: "Средневековье", desc: "Замки, рыцари и магия" },
  { id: "modern", label: "Современность", desc: "Наши дни, знакомый мир" },
  { id: "steampunk", label: "Стимпанк", desc: "Пар, шестерёнки, Викторианская эра" },
  { id: "cyberpunk", label: "Киберпанк", desc: "Неоновые города будущего" },
  { id: "postapoc", label: "Постапокалипсис", desc: "Мир после катастрофы" },
  { id: "space", label: "Космос", desc: "Далёкие галактики и планеты" },
];

const TONES = [
  { id: "light", label: "Лёгкий", desc: "Юмор, надежда, светлые темы" },
  { id: "balanced", label: "Баланс", desc: "Смесь света и тьмы" },
  { id: "dark", label: "Мрачный", desc: "Серьёзные темы, напряжение" },
  { id: "gritty", label: "Жёсткий", desc: "Реалистичный, без прикрас" },
];

export function NewCampaignScreen({ onNavigate }: NewCampaignScreenProps) {
  const [mode, setMode] = useState<"select" | "quick" | "detailed">("select");
  const [step, setStep] = useState(1);
  const [characterName, setCharacterName] = useState("");
  const [gender, setGender] = useState<string>("");
  const [selectedGenre, setSelectedGenre] = useState<string>("");
  const [selectedSetting, setSelectedSetting] = useState<string>("");
  const [selectedTone, setSelectedTone] = useState<string>("");

  const totalSteps = 4;

  const handleBack = () => {
    if (mode === "select") {
      onNavigate("home");
    } else if (step > 1) {
      setStep(step - 1);
    } else {
      setMode("select");
    }
  };

  const handleNext = () => {
    if (step < totalSteps) {
      setStep(step + 1);
    } else {
      onNavigate("game");
    }
  };

  const canProceed = () => {
    if (mode === "quick") {
      return characterName.trim().length > 0 && gender;
    }
    switch (step) {
      case 1: return selectedGenre;
      case 2: return selectedSetting;
      case 3: return selectedTone;
      case 4: return characterName.trim().length > 0 && gender;
      default: return false;
    }
  };

  return (
    <div className="min-h-screen bg-[#0A0908]">
      {/* Background */}
      <div className="pointer-events-none fixed inset-0">
        <div 
          className="absolute left-1/2 top-1/4 h-[500px] w-[500px] -translate-x-1/2 rounded-full opacity-40"
          style={{
            background: 'radial-gradient(circle, rgba(200,121,65,0.08) 0%, transparent 70%)',
          }}
        />
      </div>

      <div className="relative z-10 p-6 md:p-8 lg:p-12">
        {/* Header */}
        <header className="mb-12 flex items-center gap-6">
          <button
            onClick={handleBack}
            className="flex h-12 w-12 items-center justify-center rounded-full border border-[#1A1816] bg-[#0F0D0B] text-[#7A7570] transition-all hover:border-[#C87941]/30 hover:text-[#D4956A]"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <h1 className="font-serif text-3xl text-[#E8E4E0]">
            {mode === "select" ? "Новая история" : mode === "quick" ? "Быстрый старт" : "Создание мира"}
          </h1>
        </header>

        <div className="mx-auto max-w-2xl">
          {/* Mode selection */}
          {mode === "select" && (
            <div className="space-y-4">
              {/* Quick start */}
              <button
                onClick={() => setMode("quick")}
                className="group relative w-full overflow-hidden rounded-2xl border border-[#C87941]/20 bg-gradient-to-r from-[#C87941]/10 to-transparent p-8 text-left transition-all hover:border-[#C87941]/40"
              >
                <div className="flex items-start gap-5">
                  <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-[#C87941]/20">
                    <Zap className="h-7 w-7 text-[#C87941]" />
                  </div>
                  <div className="flex-1">
                    <h3 className="mb-2 font-serif text-2xl text-[#E8E4E0]">
                      Быстрый старт
                    </h3>
                    <p className="text-[#7A7570]">
                      ИИ подберёт случайный сеттинг и жанр. Просто введите имя героя — и в путь.
                    </p>
                  </div>
                  <ArrowRight className="h-5 w-5 text-[#C87941] transition-transform group-hover:translate-x-1" />
                </div>
              </button>

              {/* Detailed */}
              <button
                onClick={() => setMode("detailed")}
                className="group relative w-full overflow-hidden rounded-2xl border border-[#1A1816] bg-[#0F0D0B] p-8 text-left transition-all hover:border-[#BFA76F]/30"
              >
                <div className="flex items-start gap-5">
                  <div className="flex h-14 w-14 items-center justify-center rounded-2xl border border-[#1A1816] bg-[#141210]">
                    <Sparkles className="h-7 w-7 text-[#BFA76F]" />
                  </div>
                  <div className="flex-1">
                    <h3 className="mb-2 font-serif text-2xl text-[#E8E4E0]">
                      Детальная настройка
                    </h3>
                    <p className="text-[#7A7570]">
                      Выберите жанр, сеттинг, тональность и создайте персонажа с нуля.
                    </p>
                  </div>
                  <ArrowRight className="h-5 w-5 text-[#7A7570] transition-transform group-hover:translate-x-1 group-hover:text-[#BFA76F]" />
                </div>
              </button>
            </div>
          )}

          {/* Quick start */}
          {mode === "quick" && (
            <div className="space-y-8">
              <div className="text-center">
                <p className="text-[#7A7570]">
                  ИИ подберёт случайный сеттинг и жанр и сгенерирует старт истории
                </p>
              </div>

              <CharacterForm
                characterName={characterName}
                setCharacterName={setCharacterName}
                gender={gender}
                setGender={setGender}
              />

              <button
                disabled={!canProceed()}
                onClick={() => onNavigate("game")}
                className={cn(
                  "w-full rounded-xl py-4 font-medium transition-all",
                  canProceed()
                    ? "bg-[#C87941] text-[#0A0908] hover:bg-[#D4956A]"
                    : "cursor-not-allowed bg-[#1A1816] text-[#5A5550]"
                )}
              >
                Начать приключение
              </button>
            </div>
          )}

          {/* Detailed setup */}
          {mode === "detailed" && (
            <div className="space-y-8">
              {/* Progress */}
              <div className="flex items-center justify-center gap-3">
                {Array.from({ length: totalSteps }).map((_, i) => (
                  <div
                    key={i}
                    className={cn(
                      "h-1 rounded-full transition-all",
                      i + 1 <= step 
                        ? "w-8 bg-[#C87941]" 
                        : "w-4 bg-[#1A1816]"
                    )}
                  />
                ))}
              </div>
              <p className="text-center text-sm text-[#5A5550]">
                Шаг {step} из {totalSteps}
              </p>

              {/* Step 1: Genre */}
              {step === 1 && (
                <div className="space-y-6">
                  <h2 className="text-center font-serif text-2xl text-[#E8E4E0]">
                    Выберите жанр
                  </h2>
                  <div className="flex flex-wrap justify-center gap-2">
                    {GENRES.map((genre) => (
                      <button
                        key={genre.id}
                        onClick={() => setSelectedGenre(genre.id)}
                        className={cn(
                          "flex items-center gap-2 rounded-full border px-5 py-2.5 text-sm transition-all",
                          selectedGenre === genre.id
                            ? "border-[#C87941] bg-[#C87941]/15 text-[#D4956A]"
                            : "border-[#1A1816] bg-[#0F0D0B] text-[#7A7570] hover:border-[#2A2520]"
                        )}
                      >
                        {selectedGenre === genre.id && <Check className="h-4 w-4" />}
                        <span>{genre.label}</span>
                      </button>
                    ))}
                  </div>
                  <button className="mx-auto flex items-center gap-2 text-sm text-[#5A5550] hover:text-[#D4956A]">
                    <Shuffle className="h-4 w-4" />
                    Случайный жанр
                  </button>
                </div>
              )}

              {/* Step 2: Setting */}
              {step === 2 && (
                <div className="space-y-6">
                  <h2 className="text-center font-serif text-2xl text-[#E8E4E0]">
                    Сеттинг мира
                  </h2>
                  <div className="grid gap-3 sm:grid-cols-2">
                    {SETTINGS.map((setting) => (
                      <button
                        key={setting.id}
                        onClick={() => setSelectedSetting(setting.id)}
                        className={cn(
                          "rounded-xl border p-5 text-left transition-all",
                          selectedSetting === setting.id
                            ? "border-[#C87941]/50 bg-[#C87941]/10"
                            : "border-[#1A1816] bg-[#0F0D0B] hover:border-[#2A2520]"
                        )}
                      >
                        <div className="mb-1 flex items-center gap-2">
                          {selectedSetting === setting.id && (
                            <Check className="h-4 w-4 text-[#C87941]" />
                          )}
                          <span className="font-medium text-[#E8E4E0]">{setting.label}</span>
                        </div>
                        <p className="text-sm text-[#5A5550]">{setting.desc}</p>
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {/* Step 3: Tone */}
              {step === 3 && (
                <div className="space-y-6">
                  <h2 className="text-center font-serif text-2xl text-[#E8E4E0]">
                    Тональность истории
                  </h2>
                  <div className="grid gap-3 sm:grid-cols-2">
                    {TONES.map((tone) => (
                      <button
                        key={tone.id}
                        onClick={() => setSelectedTone(tone.id)}
                        className={cn(
                          "rounded-xl border p-5 text-left transition-all",
                          selectedTone === tone.id
                            ? "border-[#C87941]/50 bg-[#C87941]/10"
                            : "border-[#1A1816] bg-[#0F0D0B] hover:border-[#2A2520]"
                        )}
                      >
                        <div className="mb-1 flex items-center gap-2">
                          {selectedTone === tone.id && (
                            <Check className="h-4 w-4 text-[#C87941]" />
                          )}
                          <span className="font-medium text-[#E8E4E0]">{tone.label}</span>
                        </div>
                        <p className="text-sm text-[#5A5550]">{tone.desc}</p>
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {/* Step 4: Character */}
              {step === 4 && (
                <div className="space-y-6">
                  <h2 className="text-center font-serif text-2xl text-[#E8E4E0]">
                    Ваш персонаж
                  </h2>
                  <CharacterForm
                    characterName={characterName}
                    setCharacterName={setCharacterName}
                    gender={gender}
                    setGender={setGender}
                  />
                </div>
              )}

              {/* Navigation */}
              <div className="flex items-center justify-between">
                <button
                  onClick={handleBack}
                  className="flex items-center gap-2 text-[#7A7570] hover:text-[#E8E4E0]"
                >
                  <ArrowLeft className="h-4 w-4" />
                  <span>Назад</span>
                </button>
                <button
                  onClick={step === 4 ? () => onNavigate("game") : handleNext}
                  disabled={!canProceed()}
                  className={cn(
                    "flex items-center gap-2 rounded-full px-6 py-3 font-medium transition-all",
                    canProceed()
                      ? "bg-[#C87941] text-[#0A0908] hover:bg-[#D4956A]"
                      : "cursor-not-allowed bg-[#1A1816] text-[#5A5550]"
                  )}
                >
                  <span>{step === 4 ? "Начать" : "Далее"}</span>
                  <ArrowRight className="h-4 w-4" />
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function CharacterForm({
  characterName,
  setCharacterName,
  gender,
  setGender,
}: {
  characterName: string;
  setCharacterName: (name: string) => void;
  gender: string;
  setGender: (gender: string) => void;
}) {
  return (
    <div className="space-y-6">
      <div>
        <label className="mb-3 block text-xs font-medium uppercase tracking-[0.15em] text-[#7A7570]">
          Имя героя
        </label>
        <input
          type="text"
          value={characterName}
          onChange={(e) => setCharacterName(e.target.value)}
          placeholder="Введите имя..."
          className="w-full rounded-xl border border-[#1A1816] bg-[#0F0D0B] px-5 py-4 text-[#E8E4E0] placeholder-[#5A5550] outline-none transition-all focus:border-[#C87941]/50 focus:bg-[#141210]"
        />
      </div>

      <div>
        <label className="mb-3 block text-xs font-medium uppercase tracking-[0.15em] text-[#7A7570]">
          Пол
        </label>
        <div className="flex gap-3">
          {[
            { id: "male", label: "Мужской" },
            { id: "female", label: "Женский" },
            { id: "other", label: "Другой" },
          ].map((option) => (
            <button
              key={option.id}
              onClick={() => setGender(option.id)}
              className={cn(
                "flex flex-1 items-center justify-center gap-2 rounded-xl border py-3.5 text-sm transition-all",
                gender === option.id
                  ? "border-[#C87941]/50 bg-[#C87941]/10 text-[#D4956A]"
                  : "border-[#1A1816] bg-[#0F0D0B] text-[#7A7570] hover:border-[#2A2520]"
              )}
            >
              {gender === option.id && <Check className="h-4 w-4" />}
              {option.label}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
