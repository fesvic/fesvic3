using FESVIC.Data;
using FESVIC.Models;
using Microsoft.EntityFrameworkCore;
using OfficeOpenXml;
using static OfficeOpenXml.ExcelPackage; // ✅ Correct
using EPPlusLicenseContext = OfficeOpenXml.LicenseContext;


AppContext.SetSwitch("System.Drawing.EnableUnixSupport", true);

var builder = WebApplication.CreateBuilder(args);


#pragma warning disable CS0618 // Type or member is obsolete
ExcelPackage.LicenseContext = EPPlusLicenseContext.NonCommercial;
#pragma warning restore CS0618 // Type or member is obsolete


// Add database context using connection string from appsettings.json
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"))
);

builder.Services.AddControllersWithViews();

// Add session support
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});

// Continue building...
var app = builder.Build();

// Seed default admin if none exists
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.Migrate(); // apply migrations automatically, optional but recommended

    if (!db.Admins.Any())
    {
        db.Admins.Add(new Admin
        {
            Email = "admin@fesvic.com",
            Password = "12345"  // Ideally, hash passwords!
        });
        db.SaveChanges();
    }
}
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseSession(); // Important: Session middleware must come before authorization/authentication

app.UseRouting();


app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}"
);

app.Run();
