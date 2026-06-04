import { Link } from '@inertiajs/react';
import { LayoutGrid, Settings } from 'lucide-react';
import { NavMain } from '@/components/nav-main';
import { NavUser } from '@/components/nav-user';
import {
    Sidebar,
    SidebarContent,
    SidebarFooter,
    SidebarHeader,
    SidebarMenu,
    SidebarMenuButton,
    SidebarMenuItem,
} from '@/components/ui/sidebar';
import { dashboard } from '@/routes';
import { edit } from '@/routes/profile';
import type { NavItem } from '@/types';

const mainNavItems: NavItem[] = [
    {
        title: 'Dashboard',
        href: dashboard(),
        icon: LayoutGrid,
    },
    {
        title: 'Settings',
        href: edit(),
        icon: Settings,
    },
];

export function AppSidebar() {
    return (
        <Sidebar collapsible="icon" variant="inset">
            <SidebarHeader className="px-5 pt-6 pb-4">
                <SidebarMenu>
                    <SidebarMenuItem>
                        <SidebarMenuButton
                            size="lg"
                            asChild
                            className="h-auto rounded-none bg-transparent px-0 py-0 hover:bg-transparent"
                        >
                            <Link href={dashboard()} prefetch>
                                <div className="grid flex-1 text-left group-data-[collapsible=icon]:hidden">
                                    <span className="truncate text-2xl leading-none font-bold tracking-tight text-emerald-400">
                                        E Pay
                                    </span>
                                    <span className="mt-1 truncate text-sm text-zinc-400">
                                        Simple Wallet
                                    </span>
                                </div>
                                <div className="hidden size-10 shrink-0 items-center justify-center rounded-2xl bg-emerald-500/15 text-xl font-bold text-emerald-400 ring-1 ring-emerald-500/20 group-data-[collapsible=icon]:flex">
                                    E
                                </div>
                            </Link>
                        </SidebarMenuButton>
                    </SidebarMenuItem>
                </SidebarMenu>
            </SidebarHeader>

            <SidebarContent className="px-3">
                <NavMain items={mainNavItems} />
            </SidebarContent>

            <SidebarFooter className="px-4 pb-5">
                <NavUser />
            </SidebarFooter>
        </Sidebar>
    );
}
