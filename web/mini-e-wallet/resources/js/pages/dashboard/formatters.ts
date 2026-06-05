const currencyFormatter = new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    maximumFractionDigits: 0,
});

const dateFormatter = new Intl.DateTimeFormat('id-ID', {
    dateStyle: 'medium',
    timeStyle: 'short',
});

export function formatCurrency(amount: number): string {
    return currencyFormatter.format(amount);
}

export function formatTransferDate(value: string | null): string {
    if (!value) {
        return '-';
    }

    return dateFormatter.format(new Date(value));
}
