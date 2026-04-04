"use client";

import { useState } from "react";
import { ArrowLeft, Check, Eye, EyeOff, Globe, Cpu, Gauge, Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";

interface SettingsScreenProps {
  onNavigate: (screen: string) => void;
}

export function SettingsScreen({ onNavigate }: SettingsScreenProps) {
  const [isAdult, setIsAdult] = useState(false);
  const [language, setLanguage] = useState("ru");
  const [showApiKey, setShowApiKey] = useState(false);
  const [apiUrl, setApiUrl] = useState("https://api.deepseek.com");
  const [model, setModel] = useState("deepseek-chat");
  const [apiKey, setApiKey] = useState("");
  const [timeout, setTimeoutValue] = useState("60");
  const [runtimeMode, setRuntimeMode] = useState("smart");
  const [maxTokens, setMaxTokens] = useState("512");
  const [contextSize, setContextSize] = useState("3072");
  const [isTesting, setIsTesting] = useState(false);

  const handleTestConnection = () => {
    setIsTesting(true);
    setTimeout(() => setIsTesting(false), 2000);
  };

  return (
    <div className="min-h-screen bg-[#0A0908]">
      {/* Background */}
      <div className="pointer-events-none fixed inset-0">
        <div 
          className="absolute right-1/4 top-0 h-[400px] w-[400px] rounded-full opacity-30"
          style={{
            background: 'radial-gradient(circle, rgba(200,121,65,0.1) 0%, transparent 70%)',
          }}
        />
      </div>

      <div className="relative z-10 p-6 md:p-8 lg:p-12">
        {/* Header */}
        <header className="mb-12 flex items-center gap-6">
          <button
            onClick={() => onNavigate("home")}
            className="flex h-12 w-12 items-center justify-center rounded-full border border-[#1A1816] bg-[#0F0D0B] text-[#7A7570] transition-all hover:border-[#C87941]/30 hover:text-[#D4956A]"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <h1 className="font-serif text-3xl text-[#E8E4E0]">
            Настройки ИИ
          </h1>
        </header>

        <div className="mx-auto max-w-2xl space-y-6">
          {/* Content settings */}
          <div className="rounded-2xl border border-[#1A1816] bg-[#0F0D0B] p-6">
            <h3 className="mb-4 text-xs font-medium uppercase tracking-[0.15em] text-[#5A5550]">
              Контент
            </h3>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-[#E8E4E0]">Подтвердить 18+</p>
                <p className="text-sm text-[#5A5550]">
                  Без подтверждения ИИ избегает взрослого контента.
                </p>
              </div>
              <button
                onClick={() => setIsAdult(!isAdult)}
                className={cn(
                  "relative h-7 w-12 rounded-full transition-colors",
                  isAdult ? "bg-[#C87941]" : "bg-[#1A1816]"
                )}
              >
                <span
                  className={cn(
                    "absolute top-1 h-5 w-5 rounded-full bg-[#E8E4E0] transition-transform",
                    isAdult ? "left-6" : "left-1"
                  )}
                />
              </button>
            </div>
          </div>

          {/* Language */}
          <div className="rounded-2xl border border-[#1A1816] bg-[#0F0D0B] p-6">
            <h3 className="mb-4 flex items-center gap-2 text-xs font-medium uppercase tracking-[0.15em] text-[#5A5550]">
              <Globe className="h-4 w-4" />
              Язык приложения
            </h3>
            <div className="flex gap-3">
              {[
                { id: "ru", label: "Русский" },
                { id: "en", label: "English" },
              ].map((lang) => (
                <button
                  key={lang.id}
                  onClick={() => setLanguage(lang.id)}
                  className={cn(
                    "flex items-center gap-2 rounded-full border px-5 py-2.5 text-sm transition-all",
                    language === lang.id
                      ? "border-[#C87941]/50 bg-[#C87941]/10 text-[#D4956A]"
                      : "border-[#1A1816] bg-transparent text-[#7A7570] hover:border-[#2A2520]"
                  )}
                >
                  {language === lang.id && <Check className="h-4 w-4" />}
                  {lang.label}
                </button>
              ))}
            </div>
          </div>

          {/* API Configuration */}
          <div className="rounded-2xl border border-[#1A1816] bg-[#0F0D0B] p-6">
            <h3 className="mb-2 flex items-center gap-2 text-xs font-medium uppercase tracking-[0.15em] text-[#5A5550]">
              <Cpu className="h-4 w-4" />
              OpenAI-совместимый API
            </h3>
            <p className="mb-6 text-sm text-[#5A5550]">
              Подключите любой OpenAI-совместимый endpoint.
            </p>

            <div className="space-y-5">
              <div>
                <label className="mb-2 block text-xs font-medium uppercase tracking-[0.15em] text-[#7A7570]">
                  Базовый URL
                </label>
                <input
                  type="text"
                  value={apiUrl}
                  onChange={(e) => setApiUrl(e.target.value)}
                  className="w-full rounded-xl border border-[#1A1816] bg-[#0A0908] px-5 py-3.5 text-sm text-[#E8E4E0] outline-none transition-all focus:border-[#C87941]/40"
                />
              </div>

              <div>
                <label className="mb-2 block text-xs font-medium uppercase tracking-[0.15em] text-[#7A7570]">
                  Модель
                </label>
                <input
                  type="text"
                  value={model}
                  onChange={(e) => setModel(e.target.value)}
                  className="w-full rounded-xl border border-[#1A1816] bg-[#0A0908] px-5 py-3.5 text-sm text-[#E8E4E0] outline-none transition-all focus:border-[#C87941]/40"
                />
              </div>

              <div>
                <label className="mb-2 block text-xs font-medium uppercase tracking-[0.15em] text-[#7A7570]">
                  API-ключ
                </label>
                <div className="relative">
                  <input
                    type={showApiKey ? "text" : "password"}
                    value={apiKey}
                    onChange={(e) => setApiKey(e.target.value)}
                    placeholder="sk-..."
                    className="w-full rounded-xl border border-[#1A1816] bg-[#0A0908] px-5 py-3.5 pr-12 text-sm text-[#E8E4E0] placeholder-[#3A3530] outline-none transition-all focus:border-[#C87941]/40"
                  />
                  <button
                    onClick={() => setShowApiKey(!showApiKey)}
                    className="absolute right-4 top-1/2 -translate-y-1/2 text-[#5A5550] hover:text-[#D4956A]"
                  >
                    {showApiKey ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                  </button>
                </div>
              </div>

              <div>
                <label className="mb-2 block text-xs font-medium uppercase tracking-[0.15em] text-[#7A7570]">
                  Таймаут (секунды)
                </label>
                <input
                  type="text"
                  value={timeout}
                  onChange={(e) => setTimeoutValue(e.target.value)}
                  className="w-full rounded-xl border border-[#1A1816] bg-[#0A0908] px-5 py-3.5 text-sm text-[#E8E4E0] outline-none transition-all focus:border-[#C87941]/40"
                />
              </div>
            </div>
          </div>

          {/* Runtime settings */}
          <div className="rounded-2xl border border-[#1A1816] bg-[#0F0D0B] p-6">
            <h3 className="mb-2 flex items-center gap-2 text-xs font-medium uppercase tracking-[0.15em] text-[#5A5550]">
              <Gauge className="h-4 w-4" />
              Runtime
            </h3>
            <p className="mb-6 text-sm text-[#5A5550]">
              Управляйте длиной ответа и размером контекста.
            </p>

            <div className="space-y-5">
              <div className="flex gap-3">
                {[
                  { id: "cheap", label: "Экономно" },
                  { id: "fast", label: "Быстро" },
                  { id: "smart", label: "Умно" },
                ].map((mode) => (
                  <button
                    key={mode.id}
                    onClick={() => setRuntimeMode(mode.id)}
                    className={cn(
                      "flex items-center gap-2 rounded-full border px-5 py-2.5 text-sm transition-all",
                      runtimeMode === mode.id
                        ? "border-[#C87941]/50 bg-[#C87941]/10 text-[#D4956A]"
                        : "border-[#1A1816] bg-transparent text-[#7A7570] hover:border-[#2A2520]"
                    )}
                  >
                    {runtimeMode === mode.id && <Check className="h-4 w-4" />}
                    {mode.label}
                  </button>
                ))}
              </div>

              <div>
                <label className="mb-2 block text-xs font-medium uppercase tracking-[0.15em] text-[#7A7570]">
                  Максимум токенов ответа
                </label>
                <input
                  type="text"
                  value={maxTokens}
                  onChange={(e) => setMaxTokens(e.target.value)}
                  className="w-full rounded-xl border border-[#1A1816] bg-[#0A0908] px-5 py-3.5 text-sm text-[#E8E4E0] outline-none transition-all focus:border-[#C87941]/40"
                />
              </div>

              <div>
                <label className="mb-2 block text-xs font-medium uppercase tracking-[0.15em] text-[#7A7570]">
                  Размер окна контекста
                </label>
                <input
                  type="text"
                  value={contextSize}
                  onChange={(e) => setContextSize(e.target.value)}
                  className="w-full rounded-xl border border-[#1A1816] bg-[#0A0908] px-5 py-3.5 text-sm text-[#E8E4E0] outline-none transition-all focus:border-[#C87941]/40"
                />
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="space-y-3 pt-4">
            <button className="w-full rounded-xl bg-[#C87941] py-4 font-medium text-[#0A0908] transition-all hover:bg-[#D4956A]">
              Сохранить настройки
            </button>
            <button 
              onClick={handleTestConnection}
              disabled={isTesting}
              className="flex w-full items-center justify-center gap-2 rounded-xl border border-[#1A1816] py-4 text-[#7A7570] transition-all hover:border-[#C87941]/30 hover:text-[#D4956A]"
            >
              {isTesting ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" />
                  <span>Проверка...</span>
                </>
              ) : (
                <span>Проверить подключение</span>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
