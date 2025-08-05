\connect oc;


drop table public.customers_sink;
drop table public.products_sink;
drop table public.orders_sink;
drop table public.order_items_sink;



CREATE TABLE public.customers_sink (
	customer_id int NOT NULL PRIMARY KEY,
	email_address varchar(255) NOT NULL,
	full_name varchar(255) NOT NULL
);

CREATE TABLE public.products_sink (
	product_id int NOT NULL PRIMARY KEY,
	product_name varchar(100) NULL,
	product_category varchar(200) NULL,
	unit_price numeric NULL
);

CREATE TABLE public.orders_sink (
	order_id int NOT NULL PRIMARY KEY,
	order_datetime timestamp NOT NULL,
	customer_id int NOT NULL,
	order_status varchar(10) NOT NULL,
	store_id int NOT NULL
) ;

CREATE TABLE public.order_items_sink (
	order_id int NOT NULL,
	line_item_id int NOT NULL,
	product_id int NOT NULL,
	unit_price numeric(10, 2) NOT NULL,
	quantity int NOT NULL,
	primary key (order_id, line_item_id)
);



select count(*) from public.customers_sink union all
select count(*) from public.products_sink union all
select count(*) from public.orders_sink union all
select count(*) from public.order_items_sink;
