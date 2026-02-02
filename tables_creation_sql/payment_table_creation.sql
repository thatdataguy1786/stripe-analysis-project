CREATE TABLE payments (
    date DATE NOT NULL,
    merchant VARCHAR(20) NOT NULL,
    subscription_volume BIGINT DEFAULT 0,
    checkout_volume BIGINT DEFAULT 0,
    payment_link_volume BIGINT DEFAULT 0,
    total_volume BIGINT DEFAULT 0,
    PRIMARY KEY (date, merchant),
    FOREIGN KEY (merchant) REFERENCES merchants(merchant)
);

CREATE INDEX idx_payments_merchant ON payments(merchant);
CREATE INDEX idx_payments_date ON payments(date);