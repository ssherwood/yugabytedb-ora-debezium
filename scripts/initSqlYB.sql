
CREATE TABLE customer (
  customer_id   SERIAL PRIMARY KEY,
  date_of_birth DATE,
  full_name     VARCHAR(150) NOT NULL,
  email         VARCHAR(100),
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uc_customer_email UNIQUE (email)
);

CREATE TABLE store (
  store_id         SERIAL PRIMARY KEY,
  banner_name      VARCHAR(100) NOT NULL,
  web_address      VARCHAR(100),
  physical_address VARCHAR(512),
  postal_code      VARCHAR(10),
  latitude         NUMERIC(9,6),
  longitude        NUMERIC(9,6)
);

CREATE TABLE product (
  product_id   SERIAL PRIMARY KEY,
  product_name VARCHAR(255) NOT NULL,
  product_desc VARCHAR(512),
  unit_price   NUMERIC(10,2)
);

CREATE TABLE customer_order (
  order_id     SERIAL PRIMARY KEY,
  store_id     INTEGER NOT NULL,
  customer_id  INTEGER NOT NULL,
  order_status VARCHAR(10) NOT NULL,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT ck_order_status CHECK (order_status IN ('CANCELLED', 'COMPLETE', 'OPEN', 'PAID', 'REFUNDED', 'SHIPPED')),
  CONSTRAINT fk_store FOREIGN KEY (store_id) REFERENCES store(store_id) ON DELETE CASCADE,
  CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);

CREATE TABLE order_item (
  order_id     INTEGER NOT NULL,
  line_item_id INTEGER NOT NULL,
  product_id   INTEGER NOT NULL,
  unit_price   NUMERIC(10,2) NOT NULL,
  quantity     INTEGER NOT NULL,
  CONSTRAINT pk_order_item PRIMARY KEY (order_id, line_item_id),
  CONSTRAINT uc_order_item_product UNIQUE (order_id, product_id),
  CONSTRAINT fk_order_item_order_id FOREIGN KEY (order_id) REFERENCES customer_order(order_id) ON DELETE CASCADE,
  CONSTRAINT fk_order_item_product_id FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE
);