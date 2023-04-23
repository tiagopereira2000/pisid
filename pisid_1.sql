-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 20, 2023 at 05:20 PM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pisid`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `PreventDelete` (IN `Experience_ID` INT)   BEGIN

DECLARE inventigador_t VARCHAR(50);
DECLARE current_username VARCHAR(50);

SELECT investigador 
FROM experiencia 
WHERE Experience_ID = IDxperiencia INTO inventigador_t;


SET current_username = CURRENT_USER;
    IF (inventigador_t =! current_username) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete this experience.';
  	ELSE
    	DELETE FROM experiencia
    	WHERE Experience_ID = IDxperiencia;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `alerta`
--

CREATE TABLE `alerta` (
  `IDAlerta` int(11) NOT NULL,
  `Hora` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Sala` int(11) NOT NULL,
  `Sensor` int(11) NOT NULL,
  `Leitura` decimal(4,2) NOT NULL,
  `TipoAlerta` varchar(20) NOT NULL,
  `Mensagem` varchar(100) NOT NULL,
  `horaescrita` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `experiencia`
--

CREATE TABLE `experiencia` (
  `IDxperiencia` int(11) NOT NULL,
  `Descrição` text NOT NULL,
  `Investigador` varchar(50) NOT NULL,
  `DataHora` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `NúmeroRatos` int(11) NOT NULL,
  `LimiteRatosSala` int(11) NOT NULL,
  `SegundosSemMovimento` int(11) NOT NULL,
  `TemperaturaIdeal` decimal(4,2) NOT NULL,
  `VariaçãoTemperaturaMáxima` decimal(4,2) NOT NULL,
  `IsActive` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Triggers `experiencia`
--
DELIMITER $$
CREATE TRIGGER `PreventDelete` BEFORE DELETE ON `experiencia` FOR EACH ROW BEGIN

DECLARE current_username VARCHAR(50);
    SET current_username = USER();
    IF (OLD.Investigador != current_username) THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot delete this row.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `mediçõespassagens`
--

CREATE TABLE `mediçõespassagens` (
  `IDMedição` int(11) NOT NULL,
  `Hora` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `SalaEntrada` int(11) NOT NULL,
  `SalaSaida` int(11) NOT NULL,
  `IDxperiencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mediçõessalas`
--

CREATE TABLE `mediçõessalas` (
  `NúmeroRatosFinal` int(11) NOT NULL,
  `IDxperiencia` int(11) NOT NULL,
  `Id_mediçao` int(11) NOT NULL,
  `Sala` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mediçõestemperatura`
--

CREATE TABLE `mediçõestemperatura` (
  `IDMedição` int(11) NOT NULL,
  `Hora` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `Leitura` decimal(4,2) NOT NULL,
  `Sensor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `odoresexperiência`
--

CREATE TABLE `odoresexperiência` (
  `ID_OdorExp` int(11) NOT NULL,
  `IDExperiência` int(11) NOT NULL,
  `CódigoOdor` varchar(5) NOT NULL,
  `Sala` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sala`
--

CREATE TABLE `sala` (
  `Id_Sala` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `substânciasexperiência`
--

CREATE TABLE `substânciasexperiência` (
  `NúmeroRatos` int(11) NOT NULL,
  `CódigoSubstância` varchar(5) NOT NULL,
  `IDxperiencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `utilizador`
--

CREATE TABLE `utilizador` (
  `NomeUtilizador` varchar(100) NOT NULL,
  `TelefoneUtilizador` varchar(12) NOT NULL,
  `TipoUtilizador` varchar(3) NOT NULL,
  `EmailUtilizador` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alerta`
--
ALTER TABLE `alerta`
  ADD PRIMARY KEY (`IDAlerta`);

--
-- Indexes for table `experiencia`
--
ALTER TABLE `experiencia`
  ADD PRIMARY KEY (`IDxperiencia`),
  ADD KEY `Fk_Invs-Exp` (`Investigador`);

--
-- Indexes for table `mediçõespassagens`
--
ALTER TABLE `mediçõespassagens`
  ADD PRIMARY KEY (`IDMedição`),
  ADD KEY `Fk_SalaEntrada` (`SalaEntrada`),
  ADD KEY `Fk_SalaSaida` (`SalaSaida`),
  ADD KEY `Fk_IdExperienciaMedPAss` (`IDxperiencia`);

--
-- Indexes for table `mediçõessalas`
--
ALTER TABLE `mediçõessalas`
  ADD PRIMARY KEY (`Id_mediçao`),
  ADD KEY `IDxperiencia` (`IDxperiencia`),
  ADD KEY `Fk_SalaMediçao` (`Sala`);

--
-- Indexes for table `mediçõestemperatura`
--
ALTER TABLE `mediçõestemperatura`
  ADD PRIMARY KEY (`IDMedição`);

--
-- Indexes for table `odoresexperiência`
--
ALTER TABLE `odoresexperiência`
  ADD PRIMARY KEY (`ID_OdorExp`),
  ADD KEY `Fk_SalaOdor` (`Sala`),
  ADD KEY `Fk_idExperiencia` (`IDExperiência`);

--
-- Indexes for table `sala`
--
ALTER TABLE `sala`
  ADD PRIMARY KEY (`Id_Sala`);

--
-- Indexes for table `substânciasexperiência`
--
ALTER TABLE `substânciasexperiência`
  ADD PRIMARY KEY (`CódigoSubstância`),
  ADD KEY `Fk_IdExp` (`IDxperiencia`);

--
-- Indexes for table `utilizador`
--
ALTER TABLE `utilizador`
  ADD PRIMARY KEY (`EmailUtilizador`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alerta`
--
ALTER TABLE `alerta`
  MODIFY `IDAlerta` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `experiencia`
--
ALTER TABLE `experiencia`
  MODIFY `IDxperiencia` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mediçõespassagens`
--
ALTER TABLE `mediçõespassagens`
  MODIFY `IDMedição` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mediçõessalas`
--
ALTER TABLE `mediçõessalas`
  MODIFY `Id_mediçao` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mediçõestemperatura`
--
ALTER TABLE `mediçõestemperatura`
  MODIFY `IDMedição` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `odoresexperiência`
--
ALTER TABLE `odoresexperiência`
  MODIFY `ID_OdorExp` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sala`
--
ALTER TABLE `sala`
  MODIFY `Id_Sala` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `experiencia`
--
ALTER TABLE `experiencia`
  ADD CONSTRAINT `Fk_Invs-Exp` FOREIGN KEY (`Investigador`) REFERENCES `utilizador` (`EmailUtilizador`);

--
-- Constraints for table `mediçõespassagens`
--
ALTER TABLE `mediçõespassagens`
  ADD CONSTRAINT `Fk_IdExperienciaMedPAss` FOREIGN KEY (`IDxperiencia`) REFERENCES `experiencia` (`IDxperiencia`),
  ADD CONSTRAINT `Fk_SalaEntrada` FOREIGN KEY (`SalaEntrada`) REFERENCES `sala` (`Id_Sala`),
  ADD CONSTRAINT `Fk_SalaSaida` FOREIGN KEY (`SalaSaida`) REFERENCES `sala` (`Id_Sala`);

--
-- Constraints for table `mediçõessalas`
--
ALTER TABLE `mediçõessalas`
  ADD CONSTRAINT `Fk_SalaMediçao` FOREIGN KEY (`Sala`) REFERENCES `sala` (`Id_Sala`),
  ADD CONSTRAINT `mediçõessalas_ibfk_1` FOREIGN KEY (`IDxperiencia`) REFERENCES `experiencia` (`IDxperiencia`);

--
-- Constraints for table `odoresexperiência`
--
ALTER TABLE `odoresexperiência`
  ADD CONSTRAINT `Fk_SalaOdor` FOREIGN KEY (`Sala`) REFERENCES `sala` (`Id_Sala`),
  ADD CONSTRAINT `Fk_idExperiencia` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDxperiencia`);

--
-- Constraints for table `substânciasexperiência`
--
ALTER TABLE `substânciasexperiência`
  ADD CONSTRAINT `Fk_IdExp` FOREIGN KEY (`IDxperiencia`) REFERENCES `experiencia` (`IDxperiencia`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
