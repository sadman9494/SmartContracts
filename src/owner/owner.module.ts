import { Module } from '@nestjs/common';
import { OwnerService } from './owner.service';
import { OwnerController } from './owner.controller';
import { OwnerEntity } from './entities/owner.entity';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OwnershipRecordEntity } from 'src/ownership-record/entities/ownership-record.entity';

@Module({
  imports: [TypeOrmModule.forFeature([OwnerEntity, OwnershipRecordEntity])],
  controllers: [OwnerController],
  providers: [OwnerService],
})
export class OwnerModule {}
