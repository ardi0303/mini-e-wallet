import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from '@/components/ui/card';
import { formatCurrency } from '@/pages/dashboard/formatters';

type BalanceCardProps = {
    balance: number;
};

export function BalanceCard({ balance }: BalanceCardProps) {
    return (
        <Card className="gap-0 rounded-[28px] border-zinc-800 bg-linear-to-r from-zinc-900 via-zinc-900 to-emerald-950/40 py-0 shadow-none">
            <CardHeader className="px-7 pt-7 pb-4">
                <CardDescription className="text-sm font-medium text-zinc-400 sm:text-base">
                    Saldo aktif Anda
                </CardDescription>
                <CardTitle className="pt-2 text-3xl font-bold tracking-tight text-emerald-400 sm:text-4xl lg:text-5xl">
                    {formatCurrency(balance)}
                </CardTitle>
            </CardHeader>
            <CardContent className="px-7 pb-7 text-sm text-zinc-500 sm:text-base">
                Mini E-Wallet siap dipakai untuk transfer dan pembaruan riwayat
                transaksi secara instan.
            </CardContent>
        </Card>
    );
}
