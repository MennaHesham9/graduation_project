import type { LucideIcon } from "lucide-react";

type ActionCardProps = {
  icon: LucideIcon;
  title: string;
  iconBgClass: string;
  iconColorClass: string;
  onClick?: () => void;
};

export function ActionCard({
  icon: Icon,
  title,
  iconBgClass,
  iconColorClass,
  onClick,
}: ActionCardProps) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="flex flex-col items-center gap-3 rounded-2xl bg-white px-4 py-6 text-center shadow-md transition hover:shadow-lg active:scale-[0.98]"
    >
      <span
        className={`flex h-14 w-14 items-center justify-center rounded-2xl ${iconBgClass}`}
      >
        <Icon className={`h-7 w-7 ${iconColorClass}`} strokeWidth={2} />
      </span>
      <span className="text-sm font-semibold leading-tight text-gray-900">{title}</span>
    </button>
  );
}
