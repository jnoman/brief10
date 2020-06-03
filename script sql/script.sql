create schema vente;

use vente;

drop table if exists Categorie;

drop table if exists Commande;

drop table if exists LigneCommande;

drop table if exists LignePanier;

drop table if exists Produit;

drop table if exists Users;

/*==============================================================*/
/* Table : Categorie                                            */
/*==============================================================*/
create table Categorie
(
   idCategorie          int not null auto_increment,
   nomCategorie         varchar(254) not null unique,
   primary key (idCategorie)
);

/*==============================================================*/
/* Table : Commande                                             */
/*==============================================================*/
create table Commande
(
   idCommande           int not null auto_increment,
   idUser               int,
   dateCommande         datetime not null,
   PrixUT               float not null check(PrixUT>0),
   etat_commande        varchar(254),
   is_standard			TINYINT(1) not null,
   primary key (idCommande)
);

/*==============================================================*/
/* Table : LigneCommande                                        */
/*==============================================================*/
create table LigneCommande
(
   idProduit            int not null auto_increment,
   idCommande           int not null,
   qteLigneCommande     int not null check(qteLigneCommande>0),
   primary key (idProduit, idCommande)
);

/*==============================================================*/
/* Table : LignePanier                                          */
/*==============================================================*/
create table Panier
(
   idProduit            int not null,
   idUser               int not null,
   qteLignePanier       int not null check(qteLignePanier>0),
   primary key (idProduit, idUser)
);

/*==============================================================*/
/* Table : Produit                                              */
/*==============================================================*/
create table Produit
(
   idProduit            int not null auto_increment,
   idCategorie          int,
   nomProduit           varchar(254) not null unique,
   prix                 float not null check(prix>0),
   quantiteStock        int not null check(quantiteStock>=0),
   imageProduit         longblob not null,
   produtit_panier_standard bool default false not null,
   qte_ligne_panier_standard int default 0 not null,
   primary key (idProduit)
);

/*==============================================================*/
/* Table : User                                                 */
/*==============================================================*/
create table Users
(
   idUser               int not null auto_increment,
   nom                  varchar(254) not null,
   prenom               varchar(254) not null,
   email                varchar(254) not null unique,
   password_user        varchar(254) not null,
   type_user            varchar(254) check(type_user in('admin','client')),
   primary key (idUser)
);

insert into users(nom,prenom,email,password_user,type_user) values('admin','admin','admin@gmail.com','aaaaaaaa','admin'); 
insert into users(nom,prenom,email,password_user,type_user) values('client','user','client@gmail.com','aaaaaaaa','client');

alter table Commande add constraint FK_Association_1 foreign key (idUser)
      references Users (idUser) on delete restrict on update restrict;

alter table LigneCommande add constraint FK_Association_5 foreign key (idCommande)
      references Commande (idCommande) on delete restrict on update restrict;

alter table LigneCommande add constraint FK_Association_6 foreign key (idProduit)
      references Produit (idProduit) on delete restrict on update restrict;

alter table Panier add constraint FK_Association_3 foreign key (idProduit)
      references Produit (idProduit) on delete restrict on update restrict;

alter table Panier add constraint FK_Association_4 foreign key (idUser)
      references Users (idUser) on delete restrict on update restrict;

alter table Produit add constraint FK_Association_2 foreign key (idCategorie)
      references Categorie (idCategorie) on delete restrict on update restrict;

DROP TRIGGER IF EXISTS soustraction_quantite;
DELIMITER &&
Create Trigger soustraction_quantite 
after insert 
on lignecommande 
For each ROW 
BEGIN 
   UPDATE produit SET produit.quantiteStock = produit.quantiteStock - new.qteLigneCommande where produit.idProduit=new.idProduit; 
END&& 
DELIMITER ;

DROP TRIGGER IF EXISTS addition_quantite;
DELIMITER &&
Create Trigger addition_quantite 
after UPDATE 
on commande
For each ROW 
BEGIN 
	IF new.etat_commande = 'refuse' THEN
    	UPDATE produit SET produit.quantiteStock = produit.quantiteStock + lignecommande.qteLigneCommande 
    	where produit.idProduit=lignecommande.idProduit and lignecommande.idCommande=new.idCommande;
	END IF;
END&& 
DELIMITER ;


INSERT INTO `categorie` (`idCategorie`, `nomCategorie`) VALUES
(3, 'Electronics'),
(2, 'Toys'),
(1, 'Vêtement');