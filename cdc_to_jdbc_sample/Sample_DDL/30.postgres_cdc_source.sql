
drop table public.customers;
drop table public.products;
drop table public.orders;
drop table public.order_items;

CREATE TABLE public.customers (
	customer_id int NOT NULL PRIMARY KEY,
	email_address varchar(255) NOT NULL,
	full_name varchar(255) NOT NULL
);

CREATE TABLE public.products (
	product_id int NOT NULL PRIMARY KEY,
	product_name varchar(100) NULL,
	product_category varchar(200) NULL,
	unit_price numeric(10, 2) NULL
);

CREATE TABLE public.orders (
	order_id int NOT NULL PRIMARY KEY,
	order_datetime timestamp NOT NULL,
	customer_id int NOT NULL,
	order_status varchar(10) NOT NULL,
	store_id int NOT NULL
) ;

CREATE TABLE public.order_items (
	order_id int NOT NULL,
	line_item_id int NOT NULL,
	product_id int NOT NULL,
	unit_price numeric(10, 2) NOT NULL,
	quantity int NOT NULL,
	primary key (order_id, line_item_id)
);




CREATE OR REPLACE PROCEDURE insert_test_data(
    p_start_id INT,
    p_end_id INT,
    p_batch_size INT,
    p_delay_seconds decimal(10,3)
)
    LANGUAGE plpgsql
    AS $$
    DECLARE
    i INT;
    batch_counter INT := 0;
BEGIN
    -- customers
    FOR i IN p_start_id..p_end_id LOOP
        INSERT INTO public.customers (customer_id, email_address, full_name)
            VALUES (
            i,
            'user' || i || '@example.com',
            'Test User ' || i
        );

        batch_counter := batch_counter + 1;
        IF batch_counter % p_batch_size = 0 THEN
            PERFORM pg_sleep(p_delay_seconds);
        END IF;
        -- products
        INSERT INTO public.products (product_id, product_name, product_category, unit_price)
        VALUES (
            i,
            'Product ' || i,
            CASE WHEN i % 2 = 0 THEN 'Electronics' ELSE 'Books' END,
            ROUND((random() * 100 + 1)::numeric, 2)
        );
        IF batch_counter % p_batch_size = 0 THEN
            PERFORM pg_sleep(p_delay_seconds);
        END IF;

        -- orders
        INSERT INTO public.orders (order_id, order_datetime, customer_id, order_status, store_id)
        VALUES (
            i,
            NOW() - (p_end_id - i) * INTERVAL '1 day',
            i,
            CASE WHEN i % 3 = 0 THEN 'DONE' ELSE 'PENDING' END,
            (i % 5) + 1
        );
        IF batch_counter % p_batch_size = 0 THEN
            PERFORM pg_sleep(p_delay_seconds);
        END IF;


        -- order_items
        INSERT INTO public.order_items (order_id, line_item_id, product_id, unit_price, quantity)
        VALUES (
            i,
            1,
            i,
            ROUND((random() * 100 + 1)::numeric, 2),
            (i % 5) + 1
        );
        IF batch_counter % p_batch_size = 0 THEN
            COMMIT;
            PERFORM pg_sleep(p_delay_seconds);
        END IF;

    END LOOP;

END;
$$;



-- ID 1~10까지 데이터를 생성하면서 각 INSERT마다 1초 대기
CALL insert_test_data(1, 10000, 100, 0.0);



select count(*) from public.customers union all
select count(*) from public.products union all
select count(*) from public.orders union all
select count(*) from public.order_items;

