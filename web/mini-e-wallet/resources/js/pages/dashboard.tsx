import { Head, Link, useForm, usePage } from '@inertiajs/react';
import {
    ArrowDownLeft,
    ArrowUpRight,
    ChevronRight,
    Filter,
    Send,
} from 'lucide-react';
import InputError from '@/components/input-error';
import { Badge } from '@/components/ui/badge';
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
import type { Auth } from '@/types';

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
    const { auth } = usePage<{ auth: Auth }>().props;
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
            <div className="flex h-full flex-1 flex-col gap-6 bg-zinc-950 px-5 py-6">
                <div>
                    <h1 className="text-2xl font-semibold tracking-tight text-zinc-50 sm:text-3xl lg:text-4xl">
                        Selamat datang, {auth.user.name}
                    </h1>
                </div>

                <div className="grid gap-6 xl:grid-cols-[1.9fr_0.9fr]">
                    <div className="space-y-6">
                        <Card className="gap-0 rounded-[28px] border-zinc-800 bg-linear-to-r from-zinc-900 via-zinc-900 to-emerald-950/40 py-0 shadow-none">
                            <CardHeader className="px-7 pt-7 pb-4">
                                <CardDescription className="text-sm font-medium text-zinc-400 sm:text-base">
                                    Saldo aktif Anda
                                </CardDescription>
                                <CardTitle className="pt-2 text-3xl font-bold tracking-tight text-emerald-400 sm:text-4xl lg:text-5xl">
                                    {formatCurrency(wallet.balance)}
                                </CardTitle>
                            </CardHeader>
                            <CardContent className="px-7 pb-7 text-sm text-zinc-500 sm:text-base">
                                Mini E-Wallet siap dipakai untuk transfer dan
                                pembaruan riwayat transaksi secara instan.
                            </CardContent>
                        </Card>

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
                                            Belum ada transaksi. Coba lakukan
                                            transfer pertama Anda.
                                        </div>
                                    ) : (
                                        <div>
                                            {transactions.data.map(
                                                (transaction, index) => (
                                                    <div
                                                        key={transaction.uuid}
                                                        className={`flex flex-row justify-between gap-4 px-6 py-5 md:items-center ${
                                                            index !==
                                                            transactions.data
                                                                .length -
                                                                1
                                                                ? 'border-b border-zinc-800'
                                                                : ''
                                                        }`}
                                                    >
                                                        <div className="flex items-start gap-4">
                                                            <div
                                                                className={`mt-1 flex size-11 items-center justify-center rounded-full ${
                                                                    transaction.type ===
                                                                    'incoming'
                                                                        ? 'bg-emerald-950 text-emerald-400'
                                                                        : 'bg-rose-950/70 text-rose-300'
                                                                }`}
                                                            >
                                                                {transaction.type ===
                                                                'incoming' ? (
                                                                    <ArrowDownLeft className="size-4" />
                                                                ) : (
                                                                    <ArrowUpRight className="size-4" />
                                                                )}
                                                            </div>
                                                            <div className="space-y-1">
                                                                <div className="text-base font-medium text-zinc-100 sm:text-lg lg:text-xl">
                                                                    {transaction.type ===
                                                                    'incoming'
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
                                                                    Ref: #
                                                                    {
                                                                        transaction.reference_id
                                                                    }
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <div className="flex flex-col items-start gap-2 md:items-end">
                                                            <div
                                                                className={`text-lg font-semibold sm:text-xl lg:text-2xl ${
                                                                    transaction.type ===
                                                                    'incoming'
                                                                        ? 'text-emerald-400'
                                                                        : 'text-rose-300'
                                                                }`}
                                                            >
                                                                {transaction.type ===
                                                                'incoming'
                                                                    ? '+ '
                                                                    : '- '}
                                                                {formatCurrency(
                                                                    transaction.amount,
                                                                )}
                                                            </div>
                                                            <Badge
                                                                className={`rounded-full border-0 px-3 py-1 text-[11px] ${
                                                                    transaction.type ===
                                                                    'incoming'
                                                                        ? 'bg-emerald-950 text-emerald-300'
                                                                        : 'bg-rose-950 text-rose-200'
                                                                }`}
                                                            >
                                                                {transaction.type ===
                                                                'incoming'
                                                                    ? 'Masuk'
                                                                    : 'Keluar'}
                                                            </Badge>
                                                        </div>
                                                    </div>
                                                ),
                                            )}
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
                                                asChild={Boolean(
                                                    transactions.meta
                                                        .prev_page_url,
                                                )}
                                                disabled={
                                                    !transactions.meta
                                                        .prev_page_url
                                                }
                                                className="text-zinc-500 hover:bg-transparent hover:text-zinc-100"
                                            >
                                                {transactions.meta
                                                    .prev_page_url ? (
                                                    <Link
                                                        href={
                                                            transactions.meta
                                                                .prev_page_url
                                                        }
                                                        preserveScroll
                                                    >
                                                        Sebelumnya
                                                    </Link>
                                                ) : (
                                                    <span>Sebelumnya</span>
                                                )}
                                            </Button>
                                            <span className="text-zinc-300">
                                                Halaman{' '}
                                                {transactions.meta.current_page}{' '}
                                                / {transactions.meta.last_page}
                                            </span>
                                            <Button
                                                variant="ghost"
                                                size="sm"
                                                asChild={Boolean(
                                                    transactions.meta
                                                        .next_page_url,
                                                )}
                                                disabled={
                                                    !transactions.meta
                                                        .next_page_url
                                                }
                                                className="text-zinc-500 hover:bg-transparent hover:text-zinc-100"
                                            >
                                                {transactions.meta
                                                    .next_page_url ? (
                                                    <Link
                                                        href={
                                                            transactions.meta
                                                                .next_page_url
                                                        }
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
                    </div>

                    <Card className="h-fit gap-0 rounded-[28px] border-zinc-800 bg-zinc-950 py-0 shadow-none">
                        <CardHeader className="px-7 pt-7 pb-5">
                            <CardTitle className="flex items-center gap-3 text-2xl font-semibold tracking-tight text-zinc-50 sm:text-3xl">
                                <Send className="size-5 text-emerald-400" />
                                Transfer Dana
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="px-7 pb-7">
                            <form
                                className="space-y-5"
                                onSubmit={submitTransfer}
                            >
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
                                            className="h-14 w-full rounded-2xl border-zinc-700 bg-zinc-900 px-4 text-base text-zinc-100"
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
                                        placeholder="Rp 0"
                                        value={data.amount}
                                        onChange={(event) =>
                                            setData(
                                                'amount',
                                                event.target.value,
                                            )
                                        }
                                        aria-invalid={Boolean(errors.amount)}
                                        disabled={processing}
                                        className="rounded-2xl border-zinc-700 bg-zinc-900 px-4 text-base text-zinc-100 placeholder:text-zinc-500"
                                    />
                                    <InputError message={errors.amount} />
                                </div>

                                <Button
                                    type="submit"
                                    className="h-14 w-full rounded-full bg-emerald-400 text-zinc-950 hover:bg-emerald-300"
                                    disabled={processing}
                                >
                                    {processing && <Spinner />}
                                    Kirim sekarang
                                    <ChevronRight className="size-4" />
                                </Button>
                            </form>
                        </CardContent>
                    </Card>
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
