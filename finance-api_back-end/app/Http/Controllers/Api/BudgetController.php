<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Budget;
use App\Models\Transaction;
use Illuminate\Http\Request;

class BudgetController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $totalIncome = Transaction::where('user_id', $userId)
            ->where('type', 'income')
            ->when($request->has('month') && $request->has('year'), function ($query) use ($request) {
                $query->whereMonth('date', $request->month)
                      ->whereYear('date', $request->year);
            }, function ($query) {
                $query->whereMonth('date', now()->month)
                      ->whereYear('date', now()->year);
            })
            ->sum('amount');

        $query = Budget::with('category')
            ->where('user_id', $userId);

        if ($request->has('month') && $request->has('year')) {
            $query->where('month', $request->month)
                  ->where('year', $request->year);
        }

        $budgets = $query->get()->map(function ($budget) {
            $remaining = $budget->amount - $budget->spent;
            return [
                'id' => $budget->id,
                'user_id' => $budget->user_id,
                'category_id' => $budget->category_id,
                'category' => $budget->category,
                'amount' => $budget->amount,
                'spent' => $budget->spent,
                'remaining' => $remaining,
                'percentage' => $budget->amount > 0 ? ($budget->spent / $budget->amount) * 100 : 0,
                'month' => $budget->month,
                'year' => $budget->year,
                'created_at' => $budget->created_at,
                'updated_at' => $budget->updated_at,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'total_income' => $totalIncome,
                'budgets' => $budgets
            ]
        ]);
    }

    public function store(Request $request)
{
    $request->validate([
        'category_id' => 'required|exists:categories,id',
        'amount' => 'required|numeric|min:0',
        'month' => 'required|integer|min:1|max:12',
        'year' => 'required|integer|min:2000',
    ]);

    $userId = $request->user()->id;

    $existing = Budget::where('user_id', $userId)
        ->where('category_id', $request->category_id)
        ->where('month', $request->month)
        ->where('year', $request->year)
        ->first();

    if ($existing) {
        return response()->json([
            'success' => false,
            'message' => 'Budget untuk kategori ini pada bulan & tahun tersebut sudah ada!',
        ], 409);
    }

    $budget = Budget::create([
        'user_id' => $userId,
        'category_id' => $request->category_id,
        'amount' => $request->amount,
        'month' => $request->month,
        'year' => $request->year,
    ]);

    $budget->load('category');

    return response()->json([
        'success' => true,
        'message' => 'Budget created successfully',
        'data' => $budget
    ], 201);
}

    public function show(Request $request, $id)
    {
        $budget = Budget::with('category')
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);

        $remaining = $budget->amount - ($budget->spent ?? 0);
        
        return response()->json([
            'success' => true,
            'data' => [
                'id' => $budget->id,
                'user_id' => $budget->user_id,
                'category_id' => $budget->category_id,
                'category' => $budget->category,
                'amount' => $budget->amount,
                'spent' => $budget->spent,
                'remaining' => $remaining,
                'percentage' => $budget->amount > 0 ? ($budget->spent / $budget->amount) * 100 : 0,
                'month' => $budget->month,
                'year' => $budget->year,
                'created_at' => $budget->created_at,
                'updated_at' => $budget->updated_at,
            ]
        ]);
    }

    public function update(Request $request, $id)
    {
        $budget = Budget::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $request->validate([
            'category_id' => 'sometimes|exists:categories,id',
            'amount' => 'sometimes|numeric|min:0',
            'month' => 'sometimes|integer|min:1|max:12',
            'year' => 'sometimes|integer|min:2000',
        ]);

        $budget->update($request->all());
        $budget->load('category');

        return response()->json([
            'success' => true,
            'message' => 'Budget updated successfully',
            'data' => $budget
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $budget = Budget::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $budget->delete();

        return response()->json([
            'success' => true,
            'message' => 'Budget deleted successfully'
        ]);
    }
}
