export type Recipient = {
    id: number;
    uuid: string;
    name: string;
    email: string;
};

export type Transaction = {
    uuid: string;
    reference_id: string;
    type: 'incoming' | 'outgoing';
    counterparty_name: string | null;
    amount: number;
    transferred_at: string | null;
};

export type DashboardProps = {
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
