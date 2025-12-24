import { OwnerEntity } from "src/owner/entities/owner.entity";
import { PhoneEntity } from "src/phone/entities/phone.entity";
import { Column, Entity, ManyToOne, PrimaryGeneratedColumn } from "typeorm";

@Entity('OwnershipRecord')
export class OwnershipRecordEntity {
  @PrimaryGeneratedColumn()
  OwnershipRecordId: number;

  @ManyToOne(() => OwnerEntity, owner => owner.OwnerId, { eager: true, cascade: true })
  Owner: OwnerEntity;

  @ManyToOne(() => PhoneEntity, phone => phone.PhoneId, { eager: true, cascade: true })
  Phone: PhoneEntity;

  @Column()
  DateAcquired: Date;

  @Column()
  DateRelinquished: Date;

  @Column()
  CurrentOwner: boolean;
}
