<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function summary(Request $request)
    {
        $userId = $request->user()->id;
        $month = $request->query('month', date('m'));
        $year = $request->query('year', date('Y'));

        $totalIncome = Transaction::where('user_id', $userId)
            ->where('type', 'income')
            ->whereMonth('date', $month)
            ->whereYear('date', $year)
            ->sum('amount');

        $totalExpense = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereMonth('date', $month)
            ->whereYear('date', $year)
            ->sum('amount');

        $balance = $totalIncome - $totalExpense;

        $totalAllTimeIncome = Transaction::where('user_id', $userId)
            ->where('type', 'income')
            ->sum('amount');

        $totalAllTimeExpense = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->sum('amount');

        $recentTransactions = Transaction::with('category')
            ->where('user_id', $userId)
            ->orderBy('date', 'desc')
            ->orderBy('created_at', 'desc')
            ->limit(10)
            ->get();

        $expenseByCategory = Transaction::select('category_id', DB::raw('SUM(amount) as total'))
            ->with('category')
            ->where('user_id', $userId)
            ->where('type', 'expense')
            ->whereMonth('date', $month)
            ->whereYear('date', $year)
            ->groupBy('category_id')
            ->orderBy('total', 'desc')
            ->get();

        $incomeByCategory = Transaction::select('category_id', DB::raw('SUM(amount) as total'))
            ->with('category')
            ->where('user_id', $userId)
            ->where('type', 'income')
            ->whereMonth('date', $month)
            ->whereYear('date', $year)
            ->groupBy('category_id')
            ->orderBy('total', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'period' => [
                    'month' => (int)$month,
                    'year' => (int)$year,
                ],
                'current_month' => [
                    'income' => (float)$totalIncome,
                    'expense' => (float)$totalExpense,
                    'balance' => (float)$balance,
                ],
                'all_time' => [
                    'income' => (float)$totalAllTimeIncome,
                    'expense' => (float)$totalAllTimeExpense,
                    'balance' => (float)($totalAllTimeIncome - $totalAllTimeExpense),
                ],
                'recent_transactions' => $recentTransactions,
                'expense_by_category' => $expenseByCategory,
                'income_by_category' => $incomeByCategory,
            ]
        ]);
    }

    public function monthlyReport(Request $request)
    {
        $userId = $request->user()->id;
        $year = $request->query('year', date('Y'));

        $monthlyData = [];

        for ($month = 1; $month <= 12; $month++) {
            $income = Transaction::where('user_id', $userId)
                ->where('type', 'income')
                ->whereMonth('date', $month)
                ->whereYear('date', $year)
                ->sum('amount');

            $expense = Transaction::where('user_id', $userId)
                ->where('type', 'expense')
                ->whereMonth('date', $month)
                ->whereYear('date', $year)
                ->sum('amount');

            $monthlyData[] = [
                'month' => $month,
                'income' => (float)$income,
                'expense' => (float)$expense,
                'balance' => (float)($income - $expense),
            ];
        }

        return response()->json([
            'success' => true,
            'data' => [
                'year' => (int)$year,
                'monthly_data' => $monthlyData,
            ]
        ]);
    }
}