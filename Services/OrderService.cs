using Microsoft.EntityFrameworkCore;
using StockMgmt.Context;
using StockMgmt.DTOs;
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

    public async Task<Order> CreateAsync(OrderCreate orderCreate)
    {
        
        if (orderCreate.Quantity < 1) return null;
        var user = await _context.Users.FindAsync(orderCreate.UserId);
        if (user is null) return null;
        var product = await _context.Products.FindAsync(orderCreate.ProductId);
        if (product is null) return null;
        if (product.Stock < orderCreate.Quantity) return null;
        
        product.Stock -= orderCreate.Quantity;
        _context.Update(product);

        Order order = new()
        {
            Name = orderCreate.Name,
            Description = orderCreate.Description,
            Address = orderCreate.Address,
            PaymentMethod = orderCreate.PaymentMethod,
            Quantity = orderCreate.Quantity,
            OrderDate = DateTimeOffset.UtcNow,
            UserId = orderCreate.UserId,
            ProductId = orderCreate.ProductId,
        };
        
        await _context.Orders.AddAsync(order);
        
        await _context.SaveChangesAsync();
        
        return order;
    }

}