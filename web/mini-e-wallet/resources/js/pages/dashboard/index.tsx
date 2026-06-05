import { Head, usePage } from '@inertiajs/react';
import { BalanceCard } from '@/pages/dashboard/balance-card';
import { TransactionsSection } from '@/pages/dashboard/transactions-section';
import { TransferCard } from '@/pages/dashboard/transfer-card';
import type { DashboardProps } from '@/pages/dashboard/types';
import { WelcomeSection } from '@/pages/dashboard/welcome-section';
import { dashboard } from '@/routes';
import type { Auth } from '@/types';

export default function Dashboard({
    wallet,
    transferForm,
    transactions,
}: DashboardProps) {
    const { auth } = usePage<{ auth: Auth }>().props;

    return (
        <>
            <Head title="Dashboard" />
            <div className="flex h-full flex-1 flex-col gap-6 bg-zinc-950 px-5 py-6">
                <WelcomeSection userName={auth.user.name} />

                <div className="grid gap-6 xl:grid-cols-[1.9fr_0.9fr]">
                    <div className="space-y-6">
                        <BalanceCard balance={wallet.balance} />
                        <TransactionsSection transactions={transactions} />
                    </div>

                    <TransferCard recipients={transferForm.recipients} />
                </div>
            </div>
        </>
    );
}

Dashboard.layout = {
    breadcrumbs: [
        {
            title: 'Dashboard',
            href: dashboard(),
        },
    ],
};
