type WelcomeSectionProps = {
    userName: string;
};

export function WelcomeSection({ userName }: WelcomeSectionProps) {
    return (
        <div>
            <h1 className="text-2xl font-semibold tracking-tight text-zinc-50 sm:text-3xl lg:text-4xl">
                Selamat datang, {userName}
            </h1>
        </div>
    );
}
