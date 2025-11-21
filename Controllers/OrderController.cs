using Microsoft.AspNetCore.Mvc;
using StockMgmt.Common;
using StockMgmt.Models;
using StockMgmt.Services;

namespace StockMgmt.Controllers;

[ApiController]
[Route("/api/v1/orders")]
public class OrderController(OrderService orderService) : Controller
{
    private readonly OrderService _orderService = orderService;
    
    [HttpGet]
    public async Task<ApiResponse<List<Order>>> GetAll()
    {
        var orders = await _orderService.GetAllAsync();

        return new ApiResponse<List<Order>>()
        {
            Success = true,
            Message = "Orders listed",
            Data = orders
        };
    }

    [HttpGet("{id}")]
    public async Task<ApiResponse<Order>> Get(int id)
    {
        var order = await _orderService.GetByIdAsync(id);
        return new ApiResponse<Order>()
        {
            Success = true,
            Message = "Order found",
            Data = order
        };
    }
}