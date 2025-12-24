import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PhoneModule } from './phone/phone.module';
import { OwnerModule } from './owner/owner.module';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OwnershipRecordModule } from './ownership-record/ownership-record.module';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: '',
      port: 5432,
      username: '',
      password: '',
      database: '',
      synchronize: true,
      autoLoadEntities: true,
      ssl: true,
    }),
    PhoneModule,
    OwnerModule,
    OwnershipRecordModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
