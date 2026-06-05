import { useForm } from '@inertiajs/react';
import { ChevronRight, Send } from 'lucide-react';
import InputError from '@/components/input-error';
import { Button } from '@/components/ui/button';
import {
    Card,
    CardContent,
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
import type { DashboardProps } from '@/pages/dashboard/types';

type TransferCardProps = {
    recipients: DashboardProps['transferForm']['recipients'];
};

export function TransferCard({ recipients }: TransferCardProps) {
    const { data, setData, post, processing, errors, reset } = useForm({
        recipient_user_id: '',
        amount: '',
    });

    function submitTransfer(event: React.FormEvent<HTMLFormElement>) {
        event.preventDefault();

        post('/transfers', {
            preserveScroll: true,
            onSuccess: () => reset('recipient_user_id', 'amount'),
        });
    }

    return (
        <Card className="h-fit gap-0 rounded-[28px] border-zinc-800 bg-zinc-950 py-0 shadow-none">
            <CardHeader className="px-7 pt-7 pb-5">
                <CardTitle className="flex items-center gap-3 text-2xl font-semibold tracking-tight text-zinc-50 sm:text-3xl">
                    <Send className="size-5 text-emerald-400" />
                    Transfer Dana
                </CardTitle>
            </CardHeader>
            <CardContent className="px-7 pb-7">
                <form className="space-y-5" onSubmit={submitTransfer}>
                    <div className="space-y-2">
                        <Label htmlFor="recipient_user_id">Penerima</Label>
                        <Select
                            value={data.recipient_user_id}
                            onValueChange={(value) =>
                                setData('recipient_user_id', value)
                            }
                            disabled={processing}
                        >
                            <SelectTrigger
                                id="recipient_user_id"
                                className="h-14 rounded-2xl border-zinc-700 bg-zinc-900 px-4 text-base text-zinc-100"
                                aria-invalid={Boolean(errors.recipient_user_id)}
                            >
                                <SelectValue placeholder="Pilih penerima" />
                            </SelectTrigger>
                            <SelectContent>
                                {recipients.map((recipient) => (
                                    <SelectItem
                                        key={recipient.uuid}
                                        value={String(recipient.id)}
                                    >
                                        {recipient.name} ({recipient.email})
                                    </SelectItem>
                                ))}
                            </SelectContent>
                        </Select>
                        <InputError message={errors.recipient_user_id} />
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
                                setData('amount', event.target.value)
                            }
                            aria-invalid={Boolean(errors.amount)}
                            disabled={processing}
                            className="h-14 rounded-2xl border-zinc-700 bg-zinc-900 px-4 text-base text-zinc-100 placeholder:text-zinc-500"
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
    );
}
