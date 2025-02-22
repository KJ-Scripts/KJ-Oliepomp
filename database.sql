CREATE TABLE IF NOT EXISTS `KJ-Oliepomp` (
    `owner` VARCHAR(50) NOT NULL COMMENT 'Identificatie',
    `well_index` INT NOT NULL COMMENT 'Locatie',
    PRIMARY KEY (`owner`, `well_index`),
    INDEX `idx_owner` (`owner`),
    INDEX `idx_well_index` (`well_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
