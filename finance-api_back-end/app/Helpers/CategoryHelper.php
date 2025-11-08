<?php

namespace App\Helpers;

use App\Models\Category;

class CategoryHelper
{
    public static function createDefaultCategories($userId)
    {
        $categories = [
            ['name' => 'Gaji', 'icon' => '💼', 'color' => '#10B981', 'type' => 'income'],
            ['name' => 'Bonus', 'icon' => '🎁', 'color' => '#8B5CF6', 'type' => 'income'],
            ['name' => 'Freelance', 'icon' => '💻', 'color' => '#06B6D4', 'type' => 'income'],
            ['name' => 'Lainnya', 'icon' => '💰', 'color' => '#14B8A6', 'type' => 'income'],
            
            ['name' => 'Makanan', 'icon' => '🍔', 'color' => '#EF4444', 'type' => 'expense'],
            ['name' => 'Transportasi', 'icon' => '🚗', 'color' => '#F59E0B', 'type' => 'expense'],
            ['name' => 'Belanja', 'icon' => '🛒', 'color' => '#EC4899', 'type' => 'expense'],
            ['name' => 'Hiburan', 'icon' => '🎬', 'color' => '#A855F7', 'type' => 'expense'],
            ['name' => 'Tagihan', 'icon' => '📱', 'color' => '#6366F1', 'type' => 'expense'],
            ['name' => 'Lainnya', 'icon' => '💸', 'color' => '#64748B', 'type' => 'expense'],
        ];

        foreach ($categories as $cat) {
            Category::create([
                'user_id' => $userId,
                'name' => $cat['name'],
                'icon' => $cat['icon'],
                'color' => $cat['color'],
                'type' => $cat['type'],
            ]);
        }
    }
}