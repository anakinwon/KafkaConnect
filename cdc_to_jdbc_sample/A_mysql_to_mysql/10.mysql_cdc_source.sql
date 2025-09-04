use oc;

drop table if exists customers;
drop table if exists products;
drop table if exists orders;
drop table if exists order_items;

-- 아래 Create Table 스크립트수행.
CREATE TABLE customers (
      customer_id   int          NOT NULL PRIMARY KEY
    , email_address varchar(255) NOT NULL
    , full_name     varchar(255) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE products (
      product_id       int           NOT NULL PRIMARY KEY
    , product_name     varchar(255)  NULL
    , product_category varchar(255)  NULL
    , unit_price       decimal(10,0) NULL
) ENGINE=InnoDB;

CREATE TABLE orders (
	  order_id       int         NOT NULL PRIMARY KEY
    , order_datetime datetime    NOT NULL
    , customer_id    int         NOT NULL
    , order_status   varchar(10) NOT NULL
    , store_id       int         NOT NULL
) ENGINE=InnoDB;

CREATE TABLE order_items (
	  order_id     int            NOT NULL
    , line_item_id int            NOT NULL
    , product_id   int            NOT NULL
    , unit_price   decimal(10, 2) NOT NULL
    , quantity     int            NOT NULL
    , primary key (order_id, line_item_id)
) ENGINE=InnoDB;


select * from customers;
select * from products;
select * from orders;
select * from order_items;

/* 테스트 데이터 만드는 프로시저  */
use oc;

DELIMITER $$

DROP PROCEDURE IF EXISTS oc.CONNECT_DML_TEST$$

create procedure CONNECT_DML_TEST(
  max_customer_id INTEGER,
  max_order_id INTEGER,
	repeat_cnt INTEGER,
  upd_mod INTEGER
)
BEGIN
	DECLARE customer_idx INTEGER;
	DECLARE product_idx INTEGER;
    DECLARE product_idx_start INTEGER;
    DECLARE order_idx INTEGER;
    DECLARE line_item_idx INTEGER;
    DECLARE iter_idx INTEGER;

    SET iter_idx = 1;

	WHILE iter_idx <= repeat_cnt DO
	    SET customer_idx = max_customer_id + iter_idx;
	    SET product_idx  = max_customer_id + iter_idx;
	    SET order_idx    = max_order_id    + iter_idx;

	    insert into oc.customers values
	        ( customer_idx
	        , concat('testuser_', customer_idx)
	        , concat('testuser_', customer_idx)
	        );

	    insert into oc.products values
	        ( product_idx
	        , concat('testuser_', product_idx)
	        , concat('CATE_', product_idx)
	        , product_idx * 100
	        );

	    insert into oc.orders values
	        ( order_idx
	        , now()
	        , customer_idx
	        , 'delivered'
	        , 1
	        );

	    insert into oc.order_items values
	        ( order_idx
	        , mod(iter_idx, upd_mod)+1
	        , mod(iter_idx, upd_mod)+1
	        , 100* iter_idx/upd_mod
	        , 1
	        );

		if mod(iter_idx, upd_mod) = 0 then
	       update oc.customers set full_name = concat('updateduser_', customer_idx) where customer_id = customer_idx;
	       update oc.orders set  order_status = 'updated' where order_id = order_idx;
	       update oc.order_items set quantity = 2 where order_id = order_idx;
	    end if;

	    SET iter_idx = iter_idx + 1;
    END WHILE;
END$$

DELIMITER ;


/* 테스트 데이터 만드는 프로시저 실행 */
call CONNECT_DML_TEST(10000, 10000, 10000, 10000);
call CONNECT_DML_TEST(50, 50, 100, 5);
call CONNECT_DML_TEST(4000, 4000, 4000, 4000);


select count(*) from customers union all
select count(*) from products union all
select count(*) from orders union all
select count(*) from order_items;

