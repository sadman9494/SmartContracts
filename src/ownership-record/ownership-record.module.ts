import { Module } from '@nestjs/common';
import { OwnershipRecordService } from './ownership-record.service';
import { OwnershipRecordController } from './ownership-record.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OwnerEntity } from 'src/owner/entities/owner.entity';
import { PhoneEntity } from 'src/phone/entities/phone.entity';
import { OwnershipRecordEntity } from './entities/ownership-record.entity';

@Module({
  imports: [TypeOrmModule.forFeature([OwnershipRecordEntity, OwnerEntity, PhoneEntity])],
  controllers: [OwnershipRecordController],
  providers: [OwnershipRecordService],
})
export class OwnershipRecordModule {}
