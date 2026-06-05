import { Link } from '@inertiajs/react';
import {
    ArrowDownLeft,
    ArrowUpRight,
    ChevronRight,
    Filter,
} from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { formatCurrency, formatTransferDate } from '@/pages/dashboard/formatters';
import type { DashboardProps } from '@/pages/dashboard/types';
import { dashboard } from '@/routes';

type TransactionsSectionProps = {
    transactions: DashboardProps['transactions'];
};

export function TransactionsSection({
    transactions,
}: TransactionsSectionProps) {
    const nextSort = transactions.meta.sort === 'desc' ? 'asc' : 'desc';

    return (
        <div className="space-y-4">
            <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                <div>
                    <h2 className="text-2xl font-semibold tracking-tight text-zinc-50 sm:text-3xl">
                        Riwayat Transaksi
                    </h2>
                </div>
                <Button
                    variant="outline"
                    asChild
                    className="h-11 rounded-full border-zinc-700 bg-zinc-900 px-5 text-zinc-200 hover:bg-zinc-800 hover:text-white"
                >
                    <Link
                        href={dashboard.url({
                            query: { sort: nextSort },
                        })}
                        preserveScroll
                    >
                        <Filter className="size-4" />
                        Urutkan:{' '}
                        {transactions.meta.sort === 'desc'
                            ? 'Terbaru'
                            : 'Terlama'}
                    </Link>
                </Button>
            </div>

            <Card className="gap-0 rounded-[28px] border-zinc-800 bg-zinc-950 py-0 shadow-none">
                <CardContent className="px-0">
                    {transactions.data.length === 0 ? (
                        <div className="px-8 py-16 text-center text-sm text-zinc-500">
                            Belum ada transaksi. Coba lakukan transfer pertama
                            Anda.
                        </div>
                    ) : (
                        <div>
                            {transactions.data.map((transaction, index) => (
                                <div
                                    key={transaction.uuid}
                                    className={`flex flex-row justify-between gap-4 px-6 py-5 md:items-center ${
                                        index !== transactions.data.length - 1
                                            ? 'border-b border-zinc-800'
                                            : ''
                                    }`}
                                >
                                    <div className="flex items-start gap-4">
                                        <div
                                            className={`mt-1 flex size-11 items-center justify-center rounded-full ${
                                                transaction.type === 'incoming'
                                                    ? 'bg-emerald-950 text-emerald-400'
                                                    : 'bg-rose-950/70 text-rose-300'
                                            }`}
                                        >
                                            {transaction.type === 'incoming' ? (
                                                <ArrowDownLeft className="size-4" />
                                            ) : (
                                                <ArrowUpRight className="size-4" />
                                            )}
                                        </div>
                                        <div className="space-y-1">
                                            <div className="text-base font-medium text-zinc-100 sm:text-lg lg:text-xl">
                                                {transaction.type === 'incoming'
                                                    ? 'Transfer dari'
                                                    : 'Transfer ke'}{' '}
                                                {transaction.counterparty_name ??
                                                    '-'}
                                            </div>
                                            <div className="text-sm text-zinc-400">
                                                {formatTransferDate(
                                                    transaction.transferred_at,
                                                )}
                                            </div>
                                            <div className="text-xs text-zinc-500">
                                                Ref: #{transaction.reference_id}
                                            </div>
                                        </div>
                                    </div>
                                    <div className="flex flex-col items-start gap-2 md:items-end">
                                        <div
                                            className={`text-lg font-semibold sm:text-xl lg:text-2xl ${
                                                transaction.type === 'incoming'
                                                    ? 'text-emerald-400'
                                                    : 'text-rose-300'
                                            }`}
                                        >
                                            {transaction.type === 'incoming'
                                                ? '+ '
                                                : '- '}
                                            {formatCurrency(transaction.amount)}
                                        </div>
                                        <Badge
                                            className={`rounded-full border-0 px-3 py-1 text-[11px] ${
                                                transaction.type === 'incoming'
                                                    ? 'bg-emerald-950 text-emerald-300'
                                                    : 'bg-rose-950 text-rose-200'
                                            }`}
                                        >
                                            {transaction.type === 'incoming'
                                                ? 'Masuk'
                                                : 'Keluar'}
                                        </Badge>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}

                    <div className="flex flex-col gap-4 border-t border-zinc-800 px-6 py-5 text-sm text-zinc-500 md:flex-row md:items-center md:justify-between">
                        <div>
                            {transactions.meta.total > 0
                                ? `Menampilkan ${transactions.meta.from}-${transactions.meta.to} dari ${transactions.meta.total} transaksi`
                                : 'Belum ada data transaksi'}
                        </div>
                        <div className="flex items-center gap-5">
                            <Button
                                variant="ghost"
                                size="sm"
                                asChild={Boolean(transactions.meta.prev_page_url)}
                                disabled={!transactions.meta.prev_page_url}
                                className="text-zinc-500 hover:bg-transparent hover:text-zinc-100"
                            >
                                {transactions.meta.prev_page_url ? (
                                    <Link
                                        href={transactions.meta.prev_page_url}
                                        preserveScroll
                                    >
                                        Sebelumnya
                                    </Link>
                                ) : (
                                    <span>Sebelumnya</span>
                                )}
                            </Button>
                            <span className="text-zinc-300">
                                Halaman {transactions.meta.current_page} /{' '}
                                {transactions.meta.last_page}
                            </span>
                            <Button
                                variant="ghost"
                                size="sm"
                                asChild={Boolean(transactions.meta.next_page_url)}
                                disabled={!transactions.meta.next_page_url}
                                className="text-zinc-500 hover:bg-transparent hover:text-zinc-100"
                            >
                                {transactions.meta.next_page_url ? (
                                    <Link
                                        href={transactions.meta.next_page_url}
                                        preserveScroll
                                    >
                                        Berikutnya
                                        <ChevronRight className="size-4" />
                                    </Link>
                                ) : (
                                    <span>Berikutnya</span>
                                )}
                            </Button>
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}
