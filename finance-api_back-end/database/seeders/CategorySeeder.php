<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\Transaction;
use App\Models\Budget;
use App\Models\User;

class CategorySeeder extends Seeder
{
    /**
     * Jalankan database seeder.
     */
    public function run(): void
    {
        $user = User::first();
        if (!$user) {
            $user = User::factory()->create([
                'name' => 'Demo User',
                'email' => 'demo@example.com',
                'password' => bcrypt('password'),
            ]);
        }

        // =============================
        // Income Categories
        // =============================
        $incomeCategories = [
            ['name' => 'Gaji', 'icon' => '💼', 'color' => '#10B981', 'type' => 'income'],
            ['name' => 'Bonus', 'icon' => '🎁', 'color' => '#8B5CF6', 'type' => 'income'],
            ['name' => 'Investasi', 'icon' => '📈', 'color' => '#3B82F6', 'type' => 'income'],
            ['name' => 'Freelance', 'icon' => '💻', 'color' => '#06B6D4', 'type' => 'income'],
            ['name' => 'Lainnya', 'icon' => '💰', 'color' => '#14B8A6', 'type' => 'income'],
        ];

        // =============================
        // Expense Categories
        // =============================
        $expenseCategories = [
            ['name' => 'Makanan', 'icon' => '🍔', 'color' => '#EF4444', 'type' => 'expense'],
            ['name' => 'Transportasi', 'icon' => '🚗', 'color' => '#F59E0B', 'type' => 'expense'],
            ['name' => 'Belanja', 'icon' => '🛒', 'color' => '#EC4899', 'type' => 'expense'],
            ['name' => 'Hiburan', 'icon' => '🎬', 'color' => '#A855F7', 'type' => 'expense'],
            ['name' => 'Tagihan', 'icon' => '📱', 'color' => '#6366F1', 'type' => 'expense'],
            ['name' => 'Kesehatan', 'icon' => '🏥', 'color' => '#14B8A6', 'type' => 'expense'],
            ['name' => 'Pendidikan', 'icon' => '📚', 'color' => '#0EA5E9', 'type' => 'expense'],
            ['name' => 'Lainnya', 'icon' => '💸', 'color' => '#64748B', 'type' => 'expense'],
        ];

        // =============================
        // Simpan ke database
        // =============================
        foreach (array_merge($incomeCategories, $expenseCategories) as $cat) {
            Category::updateOrCreate(
                [
                    'user_id' => $user->id,
                    'name' => $cat['name'],
                    'type' => $cat['type']
                ],
                [
                    'icon' => $cat['icon'],
                    'color' => $cat['color']
                ]
            );
        }

        // =============================
        // Transaksi & Budget contoh
        // =============================

        $catGaji         = Category::where('name', 'Gaji')->where('user_id', $user->id)->first();
        $catMakanan      = Category::where('name', 'Makanan')->where('user_id', $user->id)->first();
        $catTransportasi = Category::where('name', 'Transportasi')->where('user_id', $user->id)->first();
        $catBelanja      = Category::where('name', 'Belanja')->where('user_id', $user->id)->first();

        // Hapus data lama
        Transaction::where('user_id', $user->id)->delete();
        Budget::where('user_id', $user->id)->delete();

        // === Income: Gaji ===
        if ($catGaji) {
            Transaction::create([
                'user_id' => $user->id,
                'category_id' => $catGaji->id,
                'amount' => 5000000.00,
                'type' => 'income',
                'description' => 'Gaji bulan November',
                'date' => now()->startOfMonth(),
            ]);
        }

        // === Expense: Makanan ===
        if ($catMakanan) {
            Transaction::create([
                'user_id' => $user->id,
                'category_id' => $catMakanan->id,
                'amount' => 50000.00,
                'type' => 'expense',
                'description' => 'Makan siang',
                'date' => now()->subDays(5),
            ]);

            Transaction::create([
                'user_id' => $user->id,
                'category_id' => $catMakanan->id,
                'amount' => 75000.00,
                'type' => 'expense',
                'description' => 'Makan malam keluarga',
                'date' => now()->subDays(3),
            ]);

            Transaction::create([
                'user_id' => $user->id,
                'category_id' => $catMakanan->id,
                'amount' => 45000.00,
                'type' => 'expense',
                'description' => 'Makan siang',
                'date' => now()->subDays(1),
            ]);

            Budget::create([
                'user_id' => $user->id,
                'category_id' => $catMakanan->id,
                'amount' => 1000000.00,
                'month' => now()->month,
                'year' => now()->year,
            ]);
        }

        // === Expense: Transportasi ===
        if ($catTransportasi) {
            Transaction::create([
                'user_id' => $user->id,
                'category_id' => $catTransportasi->id,
                'amount' => 25000.00,
                'type' => 'expense',
                'description' => 'Grab ke kantor',
                'date' => now()->subDays(4),
            ]);

            Transaction::create([
                'user_id' => $user->id,
                'category_id' => $catTransportasi->id,
                'amount' => 30000.00,
                'type' => 'expense',
                'description' => 'Bensin motor',
                'date' => now(),
            ]);

            Budget::create([
                'user_id' => $user->id,
                'category_id' => $catTransportasi->id,
                'amount' => 500000.00,
                'month' => now()->month,
                'year' => now()->year,
            ]);
        }

        // === Expense: Belanja ===
        if ($catBelanja) {
            Transaction::create([
                'user_id' => $user->id,
                'category_id' => $catBelanja->id,
                'amount' => 150000.00,
                'type' => 'expense',
                'description' => 'Belanja bulanan',
                'date' => now()->subDays(2),
            ]);

            Budget::create([
                'user_id' => $user->id,
                'category_id' => $catBelanja->id,
                'amount' => 800000.00,
                'month' => now()->month,
                'year' => now()->year,
            ]);
        }

        $this->command->info('✅ Kategori, transaksi, dan budget berhasil di-seed!');
    }
}
