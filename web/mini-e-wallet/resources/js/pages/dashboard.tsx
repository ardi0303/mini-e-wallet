import { Head, Link, useForm } from '@inertiajs/react';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import {
    Card,
    CardContent,
    CardDescription,
    CardHeader,
    CardTitle,
} from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { Spinner } from '@/components/ui/spinner';
import { dashboard } from '@/routes';

type Recipient = {
    id: number;
    uuid: string;
    name: string;
    email: string;
};

type Transaction = {
    uuid: string;
    reference_id: string;
    type: 'incoming' | 'outgoing';
    counterparty_name: string | null;
    amount: number;
    transferred_at: string | null;
};

type DashboardProps = {
    wallet: {
        uuid: string | null;
        balance: number;
    };
    transferForm: {
        recipients: Recipient[];
    };
    transactions: {
        data: Transaction[];
        meta: {
            current_page: number;
            last_page: number;
            per_page: number;
            total: number;
            from: number | null;
            to: number | null;
            sort: 'asc' | 'desc';
            prev_page_url: string | null;
            next_page_url: string | null;
        };
    };
};

const currencyFormatter = new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    maximumFractionDigits: 0,
});

const dateFormatter = new Intl.DateTimeFormat('id-ID', {
    dateStyle: 'medium',
    timeStyle: 'short',
});

function formatCurrency(amount: number): string {
    return currencyFormatter.format(amount);
}

function formatTransferDate(value: string | null): string {
    if (!value) {
        return '-';
    }

    return dateFormatter.format(new Date(value));
}

export default function Dashboard({
    wallet,
    transferForm,
    transactions,
}: DashboardProps) {
    const { data, setData, post, processing, errors, reset } = useForm({
        recipient_user_id: '',
        amount: '',
    });

    const nextSort = transactions.meta.sort === 'desc' ? 'asc' : 'desc';

    function submitTransfer(event: React.FormEvent<HTMLFormElement>) {
        event.preventDefault();

        post('/transfers', {
            preserveScroll: true,
            onSuccess: () => reset('recipient_user_id', 'amount'),
        });
    }

    return (
        <>
            <Head title="Dashboard" />
            <div className="flex h-full flex-1 flex-col gap-6 rounded-xl p-4">
                <div className="grid gap-4 lg:grid-cols-[1.2fr_0.8fr]">
                    <Card className="border-emerald-200/60 bg-gradient-to-br from-emerald-50 via-white to-cyan-50 shadow-sm dark:border-emerald-900/60 dark:from-emerald-950/40 dark:via-background dark:to-cyan-950/30">
                        <CardHeader>
                            <CardDescription>Mini E-Wallet</CardDescription>
                            <CardTitle className="text-3xl font-semibold tracking-tight">
                                Saldo aktif Anda
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div className="text-4xl font-bold tracking-tight text-emerald-700 dark:text-emerald-400">
                                {formatCurrency(wallet.balance)}
                            </div>
                            <div className="rounded-lg border border-emerald-200/70 bg-white/70 p-4 text-sm text-muted-foreground dark:border-emerald-900/60 dark:bg-emerald-950/20">
                                Transfer berhasil akan langsung memperbarui saldo
                                dan riwayat transaksi tanpa perlu login ulang.
                            </div>
                        </CardContent>
                    </Card>

                    <Card>
                        <CardHeader>
                            <CardTitle>Transfer dana</CardTitle>
                            <CardDescription>
                                Pilih penerima lalu masukkan nominal transfer.
                            </CardDescription>
                        </CardHeader>
                        <CardContent>
                            <form className="space-y-5" onSubmit={submitTransfer}>
                                <div className="space-y-2">
                                    <Label htmlFor="recipient_user_id">
                                        Penerima
                                    </Label>
                                    <Select
                                        value={data.recipient_user_id}
                                        onValueChange={(value) =>
                                            setData('recipient_user_id', value)
                                        }
                                        disabled={processing}
                                    >
                                        <SelectTrigger
                                            id="recipient_user_id"
                                            className="w-full"
                                            aria-invalid={Boolean(
                                                errors.recipient_user_id,
                                            )}
                                        >
                                            <SelectValue placeholder="Pilih penerima" />
                                        </SelectTrigger>
                                        <SelectContent>
                                            {transferForm.recipients.map(
                                                (recipient) => (
                                                    <SelectItem
                                                        key={recipient.uuid}
                                                        value={String(
                                                            recipient.id,
                                                        )}
                                                    >
                                                        {recipient.name} (
                                                        {recipient.email})
                                                    </SelectItem>
                                                ),
                                            )}
                                        </SelectContent>
                                    </Select>
                                    <InputError
                                        message={errors.recipient_user_id}
                                    />
                                </div>

                                <div className="space-y-2">
                                    <Label htmlFor="amount">Nominal</Label>
                                    <Input
                                        id="amount"
                                        type="number"
                                        min="1"
                                        step="1"
                                        inputMode="numeric"
                                        placeholder="Contoh: 50000"
                                        value={data.amount}
                                        onChange={(event) =>
                                            setData('amount', event.target.value)
                                        }
                                        aria-invalid={Boolean(errors.amount)}
                                        disabled={processing}
                                    />
                                    <InputError message={errors.amount} />
                                </div>

                                <Button
                                    type="submit"
                                    className="w-full"
                                    disabled={processing}
                                >
                                    {processing && <Spinner />}
                                    Kirim sekarang
                                </Button>
                            </form>
                        </CardContent>
                    </Card>
                </div>

                <Card>
                    <CardHeader className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
                        <div>
                            <CardTitle>Riwayat transaksi</CardTitle>
                            <CardDescription>
                                Menampilkan transfer masuk dan keluar milik akun
                                Anda.
                            </CardDescription>
                        </div>
                        <Button variant="outline" asChild>
                            <Link
                                href={dashboard.url({
                                    query: { sort: nextSort },
                                })}
                                preserveScroll
                            >
                                Urutkan:{' '}
                                {transactions.meta.sort === 'desc'
                                    ? 'Terbaru'
                                    : 'Terlama'}
                            </Link>
                        </Button>
                    </CardHeader>
                    <CardContent className="space-y-4">
                        {transactions.data.length === 0 ? (
                            <div className="rounded-lg border border-dashed p-8 text-center text-sm text-muted-foreground">
                                Belum ada transaksi. Coba lakukan transfer
                                pertama Anda.
                            </div>
                        ) : (
                            <div className="overflow-x-auto">
                                <table className="min-w-full text-sm">
                                    <thead className="text-left text-muted-foreground">
                                        <tr className="border-b">
                                            <th className="px-3 py-3 font-medium">
                                                Tanggal
                                            </th>
                                            <th className="px-3 py-3 font-medium">
                                                Jenis
                                            </th>
                                            <th className="px-3 py-3 font-medium">
                                                Lawan transaksi
                                            </th>
                                            <th className="px-3 py-3 font-medium">
                                                Referensi
                                            </th>
                                            <th className="px-3 py-3 text-right font-medium">
                                                Nominal
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {transactions.data.map((transaction) => (
                                            <tr
                                                key={transaction.uuid}
                                                className="border-b last:border-b-0"
                                            >
                                                <td className="px-3 py-4">
                                                    {formatTransferDate(
                                                        transaction.transferred_at,
                                                    )}
                                                </td>
                                                <td className="px-3 py-4">
                                                    <span
                                                        className={
                                                            transaction.type ===
                                                            'incoming'
                                                                ? 'rounded-full bg-emerald-100 px-2.5 py-1 text-xs font-medium text-emerald-700 dark:bg-emerald-950 dark:text-emerald-300'
                                                                : 'rounded-full bg-amber-100 px-2.5 py-1 text-xs font-medium text-amber-700 dark:bg-amber-950 dark:text-amber-300'
                                                        }
                                                    >
                                                        {transaction.type ===
                                                        'incoming'
                                                            ? 'Transfer masuk'
                                                            : 'Transfer keluar'}
                                                    </span>
                                                </td>
                                                <td className="px-3 py-4">
                                                    {transaction.counterparty_name ??
                                                        '-'}
                                                </td>
                                                <td className="px-3 py-4 font-mono text-xs">
                                                    {transaction.reference_id}
                                                </td>
                                                <td className="px-3 py-4 text-right font-semibold">
                                                    {transaction.type ===
                                                    'incoming'
                                                        ? '+'
                                                        : '-'}
                                                    {formatCurrency(
                                                        transaction.amount,
                                                    )}
                                                </td>
                                            </tr>
                                        ))}
                                    </tbody>
                                </table>
                            </div>
                        )}

                        <div className="flex flex-col gap-3 border-t pt-4 text-sm text-muted-foreground md:flex-row md:items-center md:justify-between">
                            <div>
                                {transactions.meta.total > 0
                                    ? `Menampilkan ${transactions.meta.from}-${transactions.meta.to} dari ${transactions.meta.total} transaksi`
                                    : 'Belum ada data transaksi'}
                            </div>
                            <div className="flex items-center gap-2">
                                <Button
                                    variant="outline"
                                    size="sm"
                                    asChild={Boolean(
                                        transactions.meta.prev_page_url,
                                    )}
                                    disabled={!transactions.meta.prev_page_url}
                                >
                                    {transactions.meta.prev_page_url ? (
                                        <Link
                                            href={
                                                transactions.meta.prev_page_url
                                            }
                                            preserveScroll
                                        >
                                            Sebelumnya
                                        </Link>
                                    ) : (
                                        <span>Sebelumnya</span>
                                    )}
                                </Button>
                                <span className="px-2">
                                    Halaman {transactions.meta.current_page} /{' '}
                                    {transactions.meta.last_page}
                                </span>
                                <Button
                                    variant="outline"
                                    size="sm"
                                    asChild={Boolean(
                                        transactions.meta.next_page_url,
                                    )}
                                    disabled={!transactions.meta.next_page_url}
                                >
                                    {transactions.meta.next_page_url ? (
                                        <Link
                                            href={
                                                transactions.meta.next_page_url
                                            }
                                            preserveScroll
                                        >
                                            Berikutnya
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
