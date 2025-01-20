use QLCHXD
--view 1: chi tiet don hang(  NgayDH, NgayYC, ngayG, TenNV, TenKH)
alter view ChiTietDonHang 
as
select Donhang.NgayDatHang, Donhang.NgayYeuCauGiao, Donhang.NgayGiao, 
NhanVien.HoTen as HoTenNhanVien, KhachHang.HoTen as HoTenKhachHang, Donhang.TongTien
from Donhang, KhachHang, NhanVien 
where Donhang.IDNhanVien=NhanVien.IDNhanVien and Donhang.IDKhachHang=KhachHang.IDKhachHang

select * from ChiTietDonHang

--view 2 chi tiet san pham( tenSP, namSX, Gia, Danhmuc, SLban, SLcon, Tencuahang)
alter view ChiTietSanPham
as 
select SanPham.TenSanPham, SanPham.NamSX, SanPham.Gia, DanhMuc.TenDanhMuc, SanPham_DonHang.SoLuong 
as SoLuongBan, TonKho.SoLuong as SoLuongCon, CuaHang.TenCuaHang
from SanPham, DanhMuc, SanPham_DonHang, TonKho, CuaHang
where SanPham.IDSanPham=SanPham_DonHang.IDSanPham and SanPham.IDDanhMuc=DanhMuc.IDDanhMuc 
and SanPham.IDSanPham=TonKho.IDSanPham and TonKho.IDCuaHang=CuaHang.IDCuaHang
select * from ChiTietSanPham



--proc: Tong gia cua mot san pham( gia*( sl ban + sl con)) bán ra và còn trong kho khi biết ID

alter proc TongGiaNhapSanPham
@tenSP nvarchar(255),
@sum float output
as begin
select @sum=sum(Gia*(soluongban+soluongcon)) from ChiTietSanPham where ChiTietSanPham.TenSanPham=@tenSP
end

declare @sum float
exec TongGiaNhapSanPham N'Xe đạp Road Twitter Gravel V2 29 inch', @sum output
print N' Tổng giá của Xe đạp Road Twitter Gravel V2 29 inch là: ' + cast(cast(@sum as numeric)as varchar) + N'VNĐ'



--proc Sản phẩm có số lượng bán ra cao nhất

create proc SPNhieuNhat
as begin
select SanPham.TenSanPham  , sum(SanPham_DonHang.SoLuong) as TongSoLuongBanRa from SanPham, SanPham_DonHang
where SanPham.IDSanPham=SanPham_DonHang.IDSanPham group by SanPham.TenSanPham having sum(SanPham_DonHang.SoLuong) >= all(
select sum(SanPham_DonHang.SoLuong) as TongSoLuongBanRa from  SanPham_DonHang
group by IDSanPham )
end

exec SPNhieuNhat

--func tổng số lượng hàng tồn của một danh mục sản phẩm
alter function SL_ton(@danhmuc nvarchar(255))
returns int as
begin 
declare @sl int;
select @sl = sum(tonkho.soluong) from TonKho, SanPham, DanhMuc
where SanPham.IDSanPham=TonKho.IDSanPham and SanPham.IDDanhMuc=DanhMuc.IDDanhMuc
and DanhMuc.IDDanhMuc=(select IDDanhMuc from DanhMuc where TenDanhMuc=@danhmuc)
return @sl
end

select TenDanhMuc, dbo.SL_ton(N'Xe đạp đua') as SoLuongBan from DanhMuc where TenDanhMuc=N'Xe đạp đua'
select * from DanhMuc


--func khachhang co don hang nhieu xe nhat
alter function khachhangmax()
returns table as return(
select KhachHang.IDKhachHang,sum(sanpham_donhang.soluong) as Soluongmua  from KhachHang,Donhang,SanPham_DonHang 
where Donhang.IDKhachHang = KhachHang.IDKhachHang and SanPham_DonHang.IDDonHang=Donhang.IDDonHang
group by KhachHang.IDKhachHang having sum(SanPham_DonHang.SoLuong) >= all(select sum(SanPham_DonHang.SoLuong) 
from KhachHang,Donhang,SanPham_DonHang 
where Donhang.IDNhanVien = KhachHang.IDKhachHang and SanPham_DonHang.IDDonHang=Donhang.IDDonHang
group by KhachHang.IDKhachHang))

select * from KhachHang where IDKhachHang = (select IDKhachHang from khachhangmax())


--trigger kiem tra so dien thoai trung
create trigger checkSDT on NhanVien after insert as
begin
if((select count(SDT) from NhanVien where SDT = (select SDT from inserted))>1)
	begin
		print N'Trùng SĐT'
		rollback tran
	end
end
--e. Con trỏ
--con trỏ để in ra tên xe đạp và số lượng xe còn lại của chuỗi của hàng
declare cur1 cursor dynamic scroll for
select SanPham.IDSanPham,sum(SoLuong) from SanPham,TonKho where SanPham.IDSanPham = TonKho.IDSanPham group by SanPham.IDSanPham
open cur1
declare @x int, @y int;
fetch first from cur1 into @x, @y;
while(@@FETCH_STATUS = 0)
begin
	declare @tensp nchar(100);
	select @tensp = TenSanPham from SanPham where IDSanPham = @x;
	print cast(@tensp as nvarchar) + N' còn ' + cast (@y as char(4)) + N'chiếc';
	fetch next from cur1 into @x, @y
end
close cur1; deallocate cur1;
-- giao dịch thêm nhân viên, khi nhân viên của mỗi cửa hàng > 5 thì không cho thêm nữa
select * from TonKho
select * from SanPham_DonHang
BEGIN tran 
insert into NhanVien values(N'Nguyễn Đức Huy', N'Nam', 'ndhuy@gmail.com','09575784743',0,1)
if ( select count(idnhanvien) from NhanVien where IDCuaHang=1) >=5
begin
print N'Cửa hàng đã đầy nhân viên'
rollback tran
end
else
begin
print N'Thêm thành công'
commit tran
end

select * from nhanvien


--Quang chung
-- cập nhật lại trường thành tiền của bảng SanPham_DonHang
create proc updateSPDH as begin
update SanPham_DonHang set ThanhTien = 
(SoLuong * (select Gia from SanPham where SanPham.IDSanPham = SanPham_DonHang.IDSanPham))*(1-GiamGia/100)
end

exec updateSPDH;

-- Cập nhật lại trường tổng tiền của bảng DonHang
create proc updateDH as begin
update Donhang set TongTien = 
(select sum(ThanhTien) from SanPham_DonHang where SanPham_DonHang.IDDonHang = Donhang.IDDonHang group by IDDonHang)
end
exec updateDH;
--b. Hàm
--số lượng xe bán theo danh mục
create function danhmucban(@dm nchar(255))
returns int as
begin
declare @sl int;
select @sl = sum(SoLuong) from SanPham_DonHang A,SanPham B,DanhMuc C 
where A.IDSanPham = B.IDSanPham and B.IDDanhMuc =C.IDDanhMuc 
and C.IDDanhMuc = (select IDDanhMuc from DanhMuc where TenDanhMuc = @dm)
if (@sl is null) 
set @sl = 0
return @sl
end

select TenDanhMuc, dbo.danhmucban(TenDanhMuc) as SoLuongBan from DanhMuc

--nhân viên lập nhiều hóa đơn cho khách nhất
create function nhanvienmax()
returns table as return(
select NhanVien.IDNhanVien,count(IDDonHang) as SoLuongDon from NhanVien,Donhang where Donhang.IDNhanVien = NhanVien.IDNhanVien 
group by NhanVien.IDNhanVien having COUNT(IDDonHang) >= all(select COUNT(IDDonHang) from NhanVien,Donhang
where Donhang.IDNhanVien = NhanVien.IDNhanVien 
group by NhanVien.IDNhanVien))

select * from NhanVien where IDNhanVien = (select IDNhanVien from nhanvienmax())
--c. Trigger
--tự cập nhật tiền kho thêm sp vào đơn
create trigger addsp_dh on SanPham_DonHang after insert as
begin
exec updateSPDH;
exec updateDH;
end

--ktra số lượng sản phẩm khi thêm sp vào đơn
create trigger SP on SanPham_DonHang instead of insert as
begin
declare @sl int, @sp int,@ch int;
select @sl = SoLuong, @sp = IDSanPham from inserted
select @ch = IDCuaHang from Donhang where IDDonHang = (select IDDonHang from inserted)
if((select SoLuong from TonKho where IDSanPham = @sp and IDCuaHang = @ch)>= @sl)
begin
insert into SanPham_DonHang select * from inserted
update TonKho set SoLuong = SoLuong - @sl where IDSanPham = @sp and IDCuaHang = @ch
end
else 
print N'Không thể thêm. Số lượng sản phẩm không đủ'
end
insert into SanPham_DonHang values(3,1,6,null,0)
--d. View
--view xem doanh thu theo ngày
create view doanhthungay as 
select NgayDatHang,sum(TongTien) as DoanhThu from Donhang group by NgayDatHang

select * from doanhthungay

--view xem doanh thu từng của hàng
create view doanhthucuahang as 
select IDCuaHang,sum(TongTien) as DoanhThu from Donhang group by IDCuaHang

select CuaHang.TenCuaHang,DoanhThu from doanhthucuahang,CuaHang where doanhthucuahang.IDCuaHang = CuaHang.IDCuaHang

--e. Con trỏ
--tạo con trỏ doanh thu theo ngày và dùng để tính ngày nào có doanh thu cao nhất
declare cur cursor dynamic scroll for
select * from doanhthungay
open cur
declare @x char(20), @y float, @max float,@nmax char(20);
fetch first from cur into @x, @y;
set @max = @y;
set @nmax = @x;
while(@@FETCH_STATUS = 0)
begin
	fetch next from cur into @x, @y
	if(@max < @y) begin 
		set @max =@y 
		set @nmax = @x
		end
end
print N'Ngày có doanh thu cao nhất là ' + cast(@nmax as char(11))
+ N', doanh thu: ' + cast(cast(@max as numeric(20))as char(20))
close cur; deallocate cur;

--Giao dịch chuyển nhân viên tên dũng ở của hàng 2 sang cửa hàng 3, nếu không có thì thông báo không thể chuyển

begin tran
update NhanVien set IDCuaHang = 3 where IDCuaHang = 2 and HoTen like N'%Dũng'
if(@@ROWCOUNT <1)
begin
	print N'Không có nhân viên tên Dũng. Không thể chuyển';
	rollback tran
end
else
begin
	print N'Chuyển thành công';
	commit tran
end
select * from NhanVien

-- hàm trả về số đơn hàng của một của hàng nào đó khi biết ID

create function sodonhang(@idcuahang char)
returns int
as
begin
declare @sl int
select @sl= count(iddonhang) from Donhang where IDCuaHang=@idcuahang
return @sl
end

print dbo.sodonhang('1')
select * from cuahang





