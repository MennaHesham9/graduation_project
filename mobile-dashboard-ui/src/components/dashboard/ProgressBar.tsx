type ProgressBarProps = {
  label: string;
  value: number;
  barClassName: string;
};

export function ProgressBar({ label, value, barClassName }: ProgressBarProps) {
  const clamped = Math.min(100, Math.max(0, value));
  return (
    <div>
      <div className="mb-2 flex items-center justify-between text-sm">
        <span className="font-medium text-gray-800">{label}</span>
        <span className="font-semibold text-gray-600">{clamped}%</span>
      </div>
      <div className="h-3 overflow-hidden rounded-full bg-gray-200/90">
        <div
          className={`h-full rounded-full transition-all ${barClassName}`}
          style={{ width: `${clamped}%` }}
          role="progressbar"
          aria-valuenow={clamped}
          aria-valuemin={0}
          aria-valuemax={100}
          aria-label={label}
        />
      </div>
    </div>
  );
}
