import { OwnershipRecordEntity } from "src/ownership-record/entities/ownership-record.entity";
import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from "typeorm";

@Entity('Phone')
export class PhoneEntity {
  @PrimaryGeneratedColumn()
  PhoneId: number;

  @Column()
  Brand: string;

  @Column()
  Model: string;

  @Column()
  Imei: string;

  @Column()
  PurchaseDate: Date;

  @Column({nullable: true})
  Origin: string;

  @Column({nullable: true})
  Status: string;

  @OneToMany(() => OwnershipRecordEntity, ownershipRecord => ownershipRecord.Phone)
  OwnershipRecords: OwnershipRecordEntity[];
}
