import { OwnershipRecordEntity } from 'src/ownership-record/entities/ownership-record.entity';
import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';

@Entity('Owner')
export class OwnerEntity {
  @PrimaryGeneratedColumn()
  OwnerId: number;

  @Column()
  FirstName: string;

  @Column()
  LastName: string;

  @Column()
  Email: string;

  @Column()
  Country: string;

  @Column()
  Address: string;

  @Column()
  Passport: string;

  @Column()
  Nid: string;

  @Column()
  City: string;

  @Column()
  State: string;

  @Column()
  Zip: string;

  @Column()
  Phone: string;

  @Column()
  OwnerType: string;

  @OneToMany(() => OwnershipRecordEntity, ownershipRecord => ownershipRecord.Owner)
  OwnershipRecords: OwnershipRecordEntity[];
}
