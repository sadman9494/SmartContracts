import { Module } from '@nestjs/common';
import { PhoneService } from './phone.service';
import { PhoneController } from './phone.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PhoneEntity } from './entities/phone.entity';
import { OwnershipRecordEntity } from 'src/ownership-record/entities/ownership-record.entity';

@Module({
  imports: [TypeOrmModule.forFeature([PhoneEntity, OwnershipRecordEntity])],
  controllers: [PhoneController],
  providers: [PhoneService],
})
export class PhoneModule {}
