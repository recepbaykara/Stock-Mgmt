using Microsoft.EntityFrameworkCore;
using StockMgmt.Context;
using StockMgmt.Models;

namespace StockMgmt.Services;

public class OrderService(AppDbContext context)
{
    private readonly AppDbContext _context = context;

    public async Task<List<Order>> GetAllAsync()
    {
        var orders = await _context.Orders.ToListAsync();
        return orders;
    }

    public async Task<Order> GetByIdAsync(int id)
    {
        var order = await _context.Orders.FindAsync(id);
        if (order is null) return null;
        return order;
    }

}