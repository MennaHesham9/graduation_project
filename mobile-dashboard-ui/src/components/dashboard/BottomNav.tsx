import {
  Calendar,
  CheckSquare,
  Home,
  Target,
  User,
} from "lucide-react";

type NavId = "home" | "tasks" | "goals" | "sessions" | "profile";

type BottomNavProps = {
  active: NavId;
  onChange?: (id: NavId) => void;
};

const items: { id: NavId; label: string; icon: typeof Home }[] = [
  { id: "home", label: "Home", icon: Home },
  { id: "tasks", label: "Tasks", icon: CheckSquare },
  { id: "goals", label: "Goals", icon: Target },
  { id: "sessions", label: "Sessions", icon: Calendar },
  { id: "profile", label: "Profile", icon: User },
];

export function BottomNav({ active, onChange }: BottomNavProps) {
  return (
    <nav
      className="absolute bottom-0 left-0 right-0 rounded-t-3xl bg-white px-2 pb-4 pt-3 shadow-[0_-8px_32px_rgba(0,0,0,0.08)]"
      aria-label="Main navigation"
    >
      <div className="flex items-end justify-between gap-1 px-1">
        {items.map(({ id, label, icon: Icon }) => {
          const isActive = active === id;
          return (
            <button
              key={id}
              type="button"
              onClick={() => onChange?.(id)}
              className={`flex min-w-0 flex-1 flex-col items-center gap-1 rounded-xl py-2 transition ${
                isActive ? "text-[#1b9aaa]" : "text-gray-400 hover:text-gray-600"
              }`}
              aria-current={isActive ? "page" : undefined}
            >
              <Icon
                className="h-6 w-6 shrink-0"
                strokeWidth={isActive ? 2.5 : 2}
                aria-hidden
              />
              <span className="truncate text-[11px] font-medium">{label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
