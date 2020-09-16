-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema examination_centers
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema examination_centers
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `examination_centers` DEFAULT CHARACTER SET utf8 ;
USE `examination_centers` ;

-- -----------------------------------------------------
-- Table `examination_centers`.`subject`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `examination_centers`.`subject` (
  `id_subject` INT(11) NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(50) NOT NULL,
  `description` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id_subject`))
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `examination_centers`.`examination`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `examination_centers`.`examination` (
  `id_examination` INT(11) NOT NULL AUTO_INCREMENT,
  `open` INT(1) NOT NULL,
  `date` DATETIME NOT NULL,
  `id_subject` INT(11) NOT NULL,
  PRIMARY KEY (`id_examination`),
  INDEX `fk_examination_subject1` (`id_subject` ASC),
  CONSTRAINT `fk_examination_subject1`
    FOREIGN KEY (`id_subject`)
    REFERENCES `examination_centers`.`subject` (`id_subject`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 5
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `examination_centers`.`class`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `examination_centers`.`class` (
  `id_class` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `address` VARCHAR(50) NOT NULL,
  `id_examination` INT(11) NOT NULL,
  PRIMARY KEY (`id_class`),
  INDEX `fk_center_examination1` (`id_examination` ASC),
  CONSTRAINT `fk_center_examination1`
    FOREIGN KEY (`id_examination`)
    REFERENCES `examination_centers`.`examination` (`id_examination`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 9
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `examination_centers`.`question`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `examination_centers`.`question` (
  `id_question` INT(11) NOT NULL AUTO_INCREMENT,
  `question` VARCHAR(500) NOT NULL,
  `answer1` VARCHAR(100) NOT NULL,
  `answer2` VARCHAR(100) NOT NULL,
  `answer3` VARCHAR(100) NOT NULL,
  `answer4` VARCHAR(100) NOT NULL,
  `correct` VARCHAR(100) NOT NULL,
  `id_subject` INT(11) NOT NULL,
  PRIMARY KEY (`id_question`),
  INDEX `fk_question_subject1` (`id_subject` ASC),
  CONSTRAINT `fk_question_subject1`
    FOREIGN KEY (`id_subject`)
    REFERENCES `examination_centers`.`subject` (`id_subject`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 51
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `examination_centers`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `examination_centers`.`user` (
  `id_user` INT(11) NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(50) NOT NULL,
  `password` VARCHAR(50) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `lastname` VARCHAR(50) NOT NULL,
  `phone` VARCHAR(50) NOT NULL,
  `address` VARCHAR(50) NOT NULL,
  `email` VARCHAR(50) NOT NULL,
  `role` INT(1) NOT NULL,
  PRIMARY KEY (`id_user`),
  UNIQUE INDEX `username_UNIQUE` (`username` ASC))
ENGINE = InnoDB
AUTO_INCREMENT = 46
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `examination_centers`.`class_has_user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `examination_centers`.`class_has_user` (
  `id_class_has_user` INT(11) NOT NULL AUTO_INCREMENT,
  `id_class` INT(11) NOT NULL,
  `id_user` INT(11) NOT NULL,
  `id_question` INT(11) NULL DEFAULT NULL,
  `answer` VARCHAR(100) NULL DEFAULT NULL,
  `date` DATETIME NULL DEFAULT NULL,
  `correct` INT(1) NULL DEFAULT NULL,
  PRIMARY KEY (`id_class_has_user`),
  INDEX `fk_examination_center_has_user_user1` (`id_user` ASC),
  INDEX `fk_class_has_user_question1_idx` (`id_question` ASC),
  INDEX `fk_examination_center_has_user_examination_center1` (`id_class` ASC),
  CONSTRAINT `fk_class_has_user_question1`
    FOREIGN KEY (`id_question`)
    REFERENCES `examination_centers`.`question` (`id_question`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_examination_center_has_user_examination_center1`
    FOREIGN KEY (`id_class`)
    REFERENCES `examination_centers`.`class` (`id_class`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_examination_center_has_user_user1`
    FOREIGN KEY (`id_user`)
    REFERENCES `examination_centers`.`user` (`id_user`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 50
DEFAULT CHARACTER SET = utf8;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
