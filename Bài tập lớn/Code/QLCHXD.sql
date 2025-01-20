create database QLCHXD
drop database QLCHXD
use QLCHXD
-- create tables
CREATE TABLE DanhMuc (
	IDDanhMuc INT IDENTITY (1, 1) PRIMARY KEY,
	TenDanhMuc VARCHAR (255) NOT NULL
);

CREATE TABLE SanPham (
	IDSanPham INT IDENTITY (1, 1) PRIMARY KEY,
	TenSanPham VARCHAR (255) NOT NULL,
	IDDanhMuc INT NOT NULL,
	NamSX SMALLINT NOT NULL,
	Gia float NOT NULL,
	FOREIGN KEY (IDDanhMuc) REFERENCES DanhMuc (IDDanhMuc)
);

CREATE TABLE KhachHang (
	IDKhachHang INT IDENTITY (1, 1) PRIMARY KEY,
	HoTen VARCHAR (255) NOT NULL,
	SDT VARCHAR (25),
	Email VARCHAR (255) NOT NULL,
	DiaChi VARCHAR (255)
);
alter table KhachHang add gioitinh nvarchar(3) check( gioitinh = N'Nam' or gioitinh = N'Nữ')
select * from NhanVien
CREATE TABLE CuaHang (
	IDCuaHang INT IDENTITY (1, 1) PRIMARY KEY,
	TenCuaHang VARCHAR (255) NOT NULL,
	SDT VARCHAR (25),
	Email VARCHAR (255),
	DiaChi VARCHAR (255)
);
alter table Nhanvien add gioitinh nvarchar(3) check( gioitinh = N'Nam' or gioitinh = N'Nữ')
CREATE TABLE NhanVien (
	IDNhanVien INT IDENTITY (1, 1) PRIMARY KEY,
	HoTen VARCHAR (50) NOT NULL,
	Email VARCHAR (255) NOT NULL UNIQUE,
	SDT VARCHAR (25),
	LamViec int NOT NULL check(LamViec = 0 or LamViec = 1),
	IDCuaHang INT NOT NULL,
	FOREIGN KEY (IDCuaHang) REFERENCES CuaHang (IDCuaHang) ,
);

CREATE TABLE Donhang (
	IDDonHang INT IDENTITY (1, 1) PRIMARY KEY,
	IDKhachHang INT,
	NgayDatHang DATE NOT NULL,
	NgayYeuCauGiao DATE NOT NULL,
	NgayGiao DATE,
	IDCuaHang INT NOT NULL,
	IDNhanVien INT NOT NULL,
	TongTien float,
	FOREIGN KEY (IDKhachHang) REFERENCES KhachHang (IDKhachHang),
	FOREIGN KEY (IDCuaHang) REFERENCES CuaHang (IDCuaHang),
	FOREIGN KEY (IDNhanVien) REFERENCES NhanVien (IDNhanVien)
);

Create TABLE SanPham_DonHang (
	IDDonHang INT,
	IDSanPham INT NOT NULL,
	SoLuong INT NOT NULL,
	ThanhTien float,
	GiamGia DECIMAL (4, 2) NOT NULL DEFAULT 0,
	PRIMARY KEY (IDDonHang, IDSanPham),
	FOREIGN KEY (IDDonHang) REFERENCES DonHang (IDDonHang),
	FOREIGN KEY (IDSanPham) REFERENCES SanPham (IDSanPham)
);

CREATE TABLE TonKho (
	IDCuaHang INT,
	IDSanPham INT,
	SoLuong INT,
	PRIMARY KEY (IDCuaHang, IDSanPham),
	FOREIGN KEY (IDCuaHang) REFERENCES CuaHang (IDCuaHang) ,
	FOREIGN KEY (IDSanPham) REFERENCES SanPham (IDSanPham) 
);

INSERT INTO DanhMuc VALUES('Children Bicycles'),
('Comfort Bicycles'),
('Cruisers Bicycles'),
('Cyclocross Bicycles'),
('Electric Bikes'),
('Mountain Bikes'),
('Road Bikes')


INSERT INTO SanPham  VALUES('Trek 820 - 2016',5,2016,379.99),
('Ritchey Timberwolf Frameset - 2017',4,2017,749.99),
('Surly Wednesday Frameset - 2018',3,2018,999.99),
('Trek Fuel EX 8 29 - 2022',2,2022,2899.99),
('Heller Shagamaw Frame - 2019',6,2019,1320.99),
('Surly Ice Cream Truck Frameset - 2020',6,2020,469.99),
('Trek Slash 8 27.5 - 2021',1,2021,3999.99),
('Trek Remedy 29 Carbon Frameset - 2016',6,2016,1799.99),
('Trek Conduit+ - 2016',5,2016,2999.99),
('Surly Straggler - 2016',4,2016,1549),
('Surly Straggler 650b - 2016',4,2016,1680.99),
('Electra Townie Original 21D - 2016',3,2016,549.99),
('Electra Cruiser 1 (24-Inch) - 2016',3,2016,269.99),
('Electra Girl''s Hawaii 1 (16-inch) - 2015/2016',3,2016,269.99),
('Electra Moto 1 - 2016',3,2016,529.99)

INSERT INTO KhachHang VALUES('Debra Burks','03857285733','debra.burks@yahoo.com','9273 Thorne Ave. '),
('Kasha Todd','05684784728','kasha.todd@yahoo.com','910 Vine Street '),
('Tameka Fisher','04937284573','tameka.fisher@aol.com','769C Honey Creek St. '),
('Daryl Spence','04937284573','daryl.spence@aol.com','988 Pearl Lane '),
('Charolette Rice','0987483756','charolette.rice@msn.com','107 River Dr. '),
('Lyndsey Bean','0957463748','lyndsey.bean@hotmail.com','769 West Road '),
('Latasha Hays','0946374638','latasha.hays@hotmail.com','7014 Manor Station Rd. '),
('Jacquline Duncan','09564756473','jacquline.duncan@yahoo.com','15 Brown St. '),
('Genoveva Baldwin','0957836583','genoveva.baldwin@msn.com','8550 Spruce Drive '),
('Pamelia Newman','0957385672','pamelia.newman@gmail.com','476 Chestnut Ave. '),
('Deshawn Mendoza','09573856387','deshawn.mendoza@yahoo.com','8790 Cobblestone Street '),
('Robby Sykes','09574676922','robby.sykes@hotmail.com','486 Rock Maple Street '),
('Lashawn Ortiz','0968467386','lashawn.ortiz@msn.com','27 Washington Rd. '),
('Garry Espinoza','0967836275','garry.espinoza@hotmail.com','7858 Rockaway Court '),
('Linnie Branch','0375866748','linnie.branch@gmail.com','314 South Columbia Ave. ')

INSERT INTO CuaHang VALUES('Santa Cruz Bikes','0375862854','santacruz@bikes.shop','3700 Portola Drive'),
      ('Baldwin Bikes','0956475843','baldwin@bikes.shop','4200 Chestnut Lane'),
      ('Rowlett Bikes','0956473895','rowlett@bikes.shop','8000 Fairway Avenue');
select * from CuaHang
INSERT INTO TonKho VALUES(1,1,27),
(1,2,5),
(1,3,6),
(1,4,23),
(1,5,22),
(1,6,0),
(1,7,8),
(1,8,0),
(1,9,11),
(1,10,15),
(1,11,8),
(1,12,16),
(1,13,13),
(1,14,8),
(1,15,3)

INSERT INTO NhanVien VALUES('Fabiola Jackson','fabiola.jackson@bikes.shop','0958365732',1,1),
('Mireya Copeland','mireya.copeland@bikes.shop','0958473756',1,1),
('Genna Serrano','genna.serrano@bikes.shop','095847637568',1,1),
('Virgie Wiggins','virgie.wiggins@bikes.shop','0375868365',1,1),
('Jannette David','jannette.david@bikes.shop','0394586858',1,2),
('Marcelene Boyer','marcelene.boyer@bikes.shop','09585734657',1,2),
('Venita Daniel','venita.daniel@bikes.shop','0957483657',1,2),
('Kali Vargas','kali.vargas@bikes.shop','09585748636',1,3),
('Layla Terrell','layla.terrell@bikes.shop','03857693765',1,3),
('Bernardine Houston','bernardine.houston@bikes.shop','09578364753',1,3);
select * from KhachHang
INSERT INTO DonHang VALUES(4,'20220101','20220103','20220103',1,2,null),
(4,'20220101','20220104','20220103',2,6,null),
(4,'20220102','20220105','20220103',3,7,null),
(4,'20220103','20220104','20220105',1,3,null),
(4,'20220103','20220106','20220106',2,6,null),
(4,'20220104','20220107','20220105',2,6,null),
(4,'20220104','20220107','20220105',3,6,null),
(4,'20220104','20220105','20220105',2,7,null),
(4,'20220105','20220108','20220108',1,2,null),
(4,'20220105','20220106','20220106',2,6,null),
(4,'20220105','20220108','20220107',2,7,null),
(4,'20220106','20220108','20220109',3,2,null),
(4,'20220108','20220111','20220111',2,6,null),
(4,'20220109','20220111','20220112',1,3,null)
select * from SanPham_DonHang
INSERT INTO SanPham_DonHang VALUES(1,1,1,null,0.2),
(1,2,2,null,0.07),
(1,3,2,null,0.05),
(1,4,2,null,0.05),
(1,5,1,null,0.2),
(2,3,1,null,0.07),
(2,4,2,null,0.05),
(3,4,1,null,0.05),
(3,5,1,null,0.05),
(4,5,2,null,0.1),
(5,6,2,null,0.05),
(5,9,1,null,0.07),
(5,7,1,null,0.07),
(6,7,1,null,0.07),
(6,8,2,null,0.05)