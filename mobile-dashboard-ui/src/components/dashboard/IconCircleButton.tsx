import type { LucideIcon } from "lucide-react";

type IconCircleButtonProps = {
  icon: LucideIcon;
  label: string;
  onClick?: () => void;
};

export function IconCircleButton({ icon: Icon, label, onClick }: IconCircleButtonProps) {
  return (
    <button
      type="button"
      aria-label={label}
      onClick={onClick}
      className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-white/20 text-white shadow-md backdrop-blur-sm transition hover:bg-white/30 active:scale-95"
    >
      <Icon className="h-5 w-5" strokeWidth={2} />
    </button>
  );
}
