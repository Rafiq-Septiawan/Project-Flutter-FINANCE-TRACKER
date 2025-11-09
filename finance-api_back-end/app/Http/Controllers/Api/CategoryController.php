<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $type = $request->query('type'); 
        
        $query = Category::where('user_id', $request->user()->id);
        
        if ($type) {
            $query->where('type', $type);
        }
        
        $categories = $query->get();

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }

    public function store(Request $request)
        {
            $request->validate([
                'name' => 'required|string|max:255',
                'type' => 'required|in:income,expense',
            ]);

            $exists = Category::where('user_id', $request->user()->id)
                ->where('name', $request->name)
                ->where('type', $request->type)
                ->exists();

            if ($exists) {
                return response()->json([
                    'success' => false,
                    'message' => 'Kategori dengan nama ini sudah ada.'
                ], 409);
            }

            $icon = $this->generateIcon($request->name);
            $color = $this->generateColor($request->name);

            $category = Category::create([
                'user_id' => $request->user()->id,
                'name' => ucfirst($request->name),
                'type' => $request->type,
                'icon' => $icon,
                'color' => $color,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Kategori berhasil ditambahkan.',
                'data' => $category
            ], 201);
        }

    private function generateIcon($name)
    {
        $name = strtolower($name);

        return match (true) {
            str_contains($name, 'makanan') => 'restaurant',
            str_contains($name, 'transport') => 'directions_car',
            str_contains($name, 'belanja') => 'shopping_cart',
            str_contains($name, 'hiburan') => 'movie',
            str_contains($name, 'tagihan') => 'receipt_long',
            str_contains($name, 'kesehatan') => 'local_hospital',
            str_contains($name, 'pendidikan') => 'school',
            str_contains($name, 'gaji') => 'work',
            str_contains($name, 'bonus') => 'card_giftcard',
            str_contains($name, 'investasi') => 'show_chart',
            str_contains($name, 'freelance') => 'computer',
            str_contains($name, 'lainnya') => 'savings',
            default => 'account_balance_wallet',
        };
    }

    private function generateColor($name)
    {
        $colors = [
            '#10B981', '#8B5CF6', '#3B82F6',
            '#06B6D4', '#14B8A6', '#EF4444',
            '#F59E0B', '#EC4899', '#A855F7',
            '#6366F1', '#0EA5E9', '#64748B'
        ];
        return $colors[array_rand($colors)];
    }

    public function show(Request $request, $id)
    {
        $category = Category::where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $category
        ]);
    }

    public function update(Request $request, $id)
    {
        $category = Category::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'type' => 'sometimes|in:income,expense',
        ]);

        // ambil data input
        $data = $request->only(['name', 'type']);

        // kalau name diubah, update juga icon & warna otomatis
        if ($request->filled('name')) {
            $data['icon'] = $this->generateIcon($request->name);
            $data['color'] = $this->generateColor($request->name);
        }

        $category->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Kategori berhasil diperbarui.',
            'data' => $category
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $category = Category::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $category->delete();

        return response()->json([
            'success' => true,
            'message' => 'Category deleted successfully'
        ]);
    }

    public function createDefaultCategories($userId)
    {
        $defaultCategories = [
            ['name' => 'Gaji', 'icon' => 'work', 'color' => '#10B981', 'type' => 'income'],
            ['name' => 'Bonus', 'icon' => 'card_giftcard', 'color' => '#8B5CF6', 'type' => 'income'],
            ['name' => 'Freelance', 'icon' => 'computer', 'color' => '#06B6D4', 'type' => 'income'],
            ['name' => 'Makanan', 'icon' => 'restaurant', 'color' => '#EF4444', 'type' => 'expense'],
            ['name' => 'Transportasi', 'icon' => 'directions_car', 'color' => '#F59E0B', 'type' => 'expense'],
            ['name' => 'Kesehatan', 'icon' => 'local_hospital', 'color' => '#E91E63', 'type' => 'expense'],
            ['name' => 'Hiburan', 'icon' => 'movie', 'color' => '#9C27B0', 'type' => 'expense'],
            ['name' => 'Belanja', 'icon' => 'shopping_cart', 'color' => '#4CAF50', 'type' => 'expense'],
        ];

        foreach ($defaultCategories as $category) {
            Category::create([
                'user_id' => $userId,
                'name' => $category['name'],
                'icon' => $category['icon'],
                'color' => $category['color'],
                'type' => $category['type'],
            ]);
        }

        return true;
    }
}