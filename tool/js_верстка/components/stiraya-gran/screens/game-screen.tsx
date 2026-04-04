"use client";

import { useState, useRef, useEffect } from "react";
import { 
  ArrowLeft, 
  BookOpen, 
  Bookmark, 
  ChevronRight, 
  Heart, 
  Menu, 
  Send,
  Settings,
  Sparkles,
  X,
  Zap,
  MoreHorizontal
} from "lucide-react";
import { cn } from "@/lib/utils";

interface GameScreenProps {
  onNavigate: (screen: string) => void;
}

const MOCK_CHARACTER = {
  name: "Лёха",
  title: "Мастер фонариков",
  genre: "Уютное фэнтези",
  location: "Мастерская Лёхи",
  turn: 1,
  stats: {
    health: { current: 12, max: 12 },
    energy: { current: 8, max: 8 },
    strength: 3,
    intellect: 5,
    spirit: 2,
  },
  inventory: ["Полевые записи", "Дорожный набор"],
  notes: "Новый день в Росариуме. Возможно, стоит навести порядок в мастерской или прогуляться по городу.",
};

const MOCK_NARRATIVE = `Утро в Росариуме начиналось с тихого звона хрустальных колокольчиков, разносимого лёгким ветерком. Воздух пах свежеиспечённым хлебом и влажной землёй после ночного дождика.

Ты, Лёха, стоял на пороге своей небольшой мастерской по ремонту волшебных фонариков, с теплотой глядя на уютные улочки, где уже просыпалась жизнь. В кармане пальто лежали твои полевые записи — мысли и зарисовки о местных светящихся мхах, которые ты надеялся однажды использовать в своих работах.

В душе тихо щемило от знакомого чувства одиночества, смешанного с тихой надеждой на то, что сегодняшний день принесёт что-то новое.`;

const SUGGESTED_ACTIONS = [
  { id: 1, text: "Осмотреть мастерскую" },
  { id: 2, text: "Выйти на улицу" },
  { id: 3, text: "Проверить записи" },
];

export function GameScreen({ onNavigate }: GameScreenProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [input, setInput] = useState("");
  const [isGenerating, setIsGenerating] = useState(false);
  const [messages, setMessages] = useState<Array<{ type: "narrative" | "action"; content: string }>>([
    { type: "narrative", content: MOCK_NARRATIVE },
  ]);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleSend = () => {
    if (!input.trim()) return;
    
    setMessages((prev) => [...prev, { type: "action", content: input }]);
    setInput("");
    setIsGenerating(true);

    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        {
          type: "narrative",
          content: "Ты решаешь осмотреться в мастерской. На полках аккуратно расставлены фонарики разных форм и размеров — некоторые ждут ремонта, другие уже готовы к возвращению владельцам. Солнечный луч пробивается сквозь запылённое окно, выхватывая танцующие пылинки...",
        },
      ]);
      setIsGenerating(false);
    }, 2000);
  };

  return (
    <div className="flex h-screen flex-col bg-[#0A0908]">
      {/* Header */}
      <header className="flex items-center justify-between border-b border-[#1A1816] px-4 py-3 md:px-6">
        <div className="flex items-center gap-4">
          <button
            onClick={() => onNavigate("home")}
            className="flex h-10 w-10 items-center justify-center rounded-full border border-[#1A1816] bg-[#0F0D0B] text-[#7A7570] transition-all hover:border-[#C87941]/30 hover:text-[#D4956A]"
          >
            <ArrowLeft className="h-4 w-4" />
          </button>
          <div>
            <h1 className="font-serif text-lg text-[#E8E4E0]">
              {MOCK_CHARACTER.name}
            </h1>
            <p className="text-xs text-[#5A5550]">{MOCK_CHARACTER.genre}</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <span className="mr-2 rounded-full bg-[#1A1816] px-3 py-1 text-xs text-[#7A7570]">
            Ход {MOCK_CHARACTER.turn}
          </span>
          <button className="flex h-10 w-10 items-center justify-center rounded-full border border-[#1A1816] text-[#7A7570] transition-all hover:border-[#C87941]/30 hover:text-[#D4956A]">
            <Bookmark className="h-4 w-4" />
          </button>
          <button 
            onClick={() => onNavigate("settings")}
            className="flex h-10 w-10 items-center justify-center rounded-full border border-[#1A1816] text-[#7A7570] transition-all hover:border-[#C87941]/30 hover:text-[#D4956A]"
          >
            <Settings className="h-4 w-4" />
          </button>
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="flex h-10 w-10 items-center justify-center rounded-full border border-[#1A1816] text-[#7A7570] transition-all hover:border-[#C87941]/30 hover:text-[#D4956A] lg:hidden"
          >
            <Menu className="h-4 w-4" />
          </button>
        </div>
      </header>

      <div className="flex flex-1 overflow-hidden">
        {/* Sidebar - Character panel */}
        <aside
          className={cn(
            "fixed inset-y-0 left-0 z-50 w-80 transform border-r border-[#1A1816] bg-[#0A0908] transition-transform lg:static lg:translate-x-0",
            sidebarOpen ? "translate-x-0" : "-translate-x-full"
          )}
        >
          <div className="flex h-full flex-col p-5">
            {/* Mobile close */}
            <button
              onClick={() => setSidebarOpen(false)}
              className="absolute right-4 top-4 text-[#5A5550] hover:text-[#E8E4E0] lg:hidden"
            >
              <X className="h-5 w-5" />
            </button>

            {/* Character header */}
            <div className="mb-6 flex items-center gap-4">
              <div className="flex h-16 w-16 items-center justify-center rounded-2xl border border-[#C87941]/30 bg-[#C87941]/10">
                <span className="font-serif text-2xl text-[#C87941]">
                  {MOCK_CHARACTER.name[0]}
                </span>
              </div>
              <div>
                <h2 className="font-serif text-xl text-[#E8E4E0]">{MOCK_CHARACTER.name}</h2>
                <p className="text-sm text-[#7A7570]">{MOCK_CHARACTER.title}</p>
              </div>
            </div>

            <div className="flex-1 space-y-6 overflow-y-auto">
              {/* Location */}
              <div>
                <h4 className="mb-2 text-xs font-medium uppercase tracking-[0.15em] text-[#5A5550]">
                  Локация
                </h4>
                <p className="text-sm text-[#E8E4E0]">{MOCK_CHARACTER.location}</p>
              </div>

              {/* Stats */}
              <div>
                <h4 className="mb-3 text-xs font-medium uppercase tracking-[0.15em] text-[#5A5550]">
                  Характеристики
                </h4>
                <div className="space-y-3">
                  <div>
                    <div className="mb-1 flex items-center justify-between text-xs">
                      <div className="flex items-center gap-2 text-[#7A7570]">
                        <Heart className="h-3.5 w-3.5 text-red-400/70" />
                        <span>Здоровье</span>
                      </div>
                      <span className="text-[#E8E4E0]">
                        {MOCK_CHARACTER.stats.health.current}/{MOCK_CHARACTER.stats.health.max}
                      </span>
                    </div>
                    <div className="h-1.5 overflow-hidden rounded-full bg-[#1A1816]">
                      <div 
                        className="h-full rounded-full bg-red-400/50" 
                        style={{ width: `${(MOCK_CHARACTER.stats.health.current / MOCK_CHARACTER.stats.health.max) * 100}%` }}
                      />
                    </div>
                  </div>
                  <div>
                    <div className="mb-1 flex items-center justify-between text-xs">
                      <div className="flex items-center gap-2 text-[#7A7570]">
                        <Zap className="h-3.5 w-3.5 text-amber-400/70" />
                        <span>Энергия</span>
                      </div>
                      <span className="text-[#E8E4E0]">
                        {MOCK_CHARACTER.stats.energy.current}/{MOCK_CHARACTER.stats.energy.max}
                      </span>
                    </div>
                    <div className="h-1.5 overflow-hidden rounded-full bg-[#1A1816]">
                      <div 
                        className="h-full rounded-full bg-amber-400/50" 
                        style={{ width: `${(MOCK_CHARACTER.stats.energy.current / MOCK_CHARACTER.stats.energy.max) * 100}%` }}
                      />
                    </div>
                  </div>
                  <div className="flex gap-3 pt-2 text-xs text-[#5A5550]">
                    <span>Сила <span className="text-[#E8E4E0]">{MOCK_CHARACTER.stats.strength}</span></span>
                    <span>Ум <span className="text-[#E8E4E0]">{MOCK_CHARACTER.stats.intellect}</span></span>
                    <span>Дух <span className="text-[#E8E4E0]">{MOCK_CHARACTER.stats.spirit}</span></span>
                  </div>
                </div>
              </div>

              {/* Inventory */}
              <div>
                <h4 className="mb-2 text-xs font-medium uppercase tracking-[0.15em] text-[#5A5550]">
                  Инвентарь
                </h4>
                <ul className="space-y-1.5">
                  {MOCK_CHARACTER.inventory.map((item, i) => (
                    <li key={i} className="flex items-center gap-2 text-sm text-[#7A7570]">
                      <div className="h-1 w-1 rounded-full bg-[#C87941]/50" />
                      {item}
                    </li>
                  ))}
                </ul>
              </div>

              {/* Notes */}
              <div>
                <h4 className="mb-2 text-xs font-medium uppercase tracking-[0.15em] text-[#5A5550]">
                  Заметки
                </h4>
                <p className="text-sm leading-relaxed text-[#7A7570]">
                  {MOCK_CHARACTER.notes}
                </p>
              </div>
            </div>
          </div>
        </aside>

        {/* Overlay */}
        {sidebarOpen && (
          <div
            className="fixed inset-0 z-40 bg-black/60 lg:hidden"
            onClick={() => setSidebarOpen(false)}
          />
        )}

        {/* Main content */}
        <main className="flex flex-1 flex-col overflow-hidden">
          {/* Narrative area */}
          <div className="flex-1 overflow-y-auto p-6 md:p-8 lg:p-12">
            <div className="mx-auto max-w-2xl space-y-8">
              {messages.map((message, index) => (
                <div key={index}>
                  {message.type === "narrative" && (
                    <div className="prose prose-invert max-w-none">
                      <p className="whitespace-pre-wrap font-serif text-lg leading-[1.8] text-[#C8C4C0]">
                        {message.content}
                      </p>
                    </div>
                  )}
                  {message.type === "action" && (
                    <div className="flex justify-end">
                      <div className="rounded-2xl border border-[#C87941]/30 bg-[#C87941]/10 px-5 py-3 text-[#D4956A]">
                        {message.content}
                      </div>
                    </div>
                  )}
                </div>
              ))}

              {isGenerating && (
                <div className="flex items-center gap-3 text-[#C87941]">
                  <Sparkles className="h-4 w-4 animate-flicker" />
                  <span className="text-sm">Рассказчик пишет</span>
                  <span className="flex gap-1">
                    <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-[#C87941]" style={{ animationDelay: "0ms" }} />
                    <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-[#C87941]" style={{ animationDelay: "150ms" }} />
                    <span className="h-1.5 w-1.5 animate-bounce rounded-full bg-[#C87941]" style={{ animationDelay: "300ms" }} />
                  </span>
                </div>
              )}

              <div ref={messagesEndRef} />
            </div>
          </div>

          {/* Suggested actions */}
          <div className="border-t border-[#1A1816] px-4 py-4 md:px-6">
            <div className="mx-auto flex max-w-2xl gap-2 overflow-x-auto">
              {SUGGESTED_ACTIONS.map((action) => (
                <button
                  key={action.id}
                  onClick={() => setInput(action.text)}
                  className="flex shrink-0 items-center gap-2 rounded-full border border-[#1A1816] bg-[#0F0D0B] px-4 py-2.5 text-sm text-[#7A7570] transition-all hover:border-[#C87941]/30 hover:text-[#D4956A]"
                >
                  <ChevronRight className="h-3.5 w-3.5" />
                  {action.text}
                </button>
              ))}
              <button className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full border border-[#1A1816] text-[#5A5550] hover:text-[#7A7570]">
                <MoreHorizontal className="h-4 w-4" />
              </button>
            </div>
          </div>

          {/* Input area */}
          <div className="border-t border-[#1A1816] p-4 md:px-6">
            <div className="mx-auto max-w-2xl">
              <div className="flex items-center gap-3">
                <input
                  type="text"
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && handleSend()}
                  placeholder="Что делает герой дальше?"
                  className="flex-1 rounded-xl border border-[#1A1816] bg-[#0F0D0B] px-5 py-4 text-[#E8E4E0] placeholder-[#5A5550] outline-none transition-all focus:border-[#C87941]/40 focus:bg-[#141210]"
                />
                <button
                  onClick={handleSend}
                  disabled={!input.trim() || isGenerating}
                  className={cn(
                    "flex h-14 w-14 items-center justify-center rounded-xl transition-all",
                    input.trim() && !isGenerating
                      ? "bg-[#C87941] text-[#0A0908] hover:bg-[#D4956A]"
                      : "bg-[#1A1816] text-[#5A5550]"
                  )}
                >
                  <Send className="h-5 w-5" />
                </button>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}
