import { OwnerDto } from "src/owner/dto/owner.dto";
import { PhoneDto } from "src/phone/dto/phone.dto";

export class OwnershipRecordDto {
  OwnershipRecordId: number;
  Owner: OwnerDto;
  Phone: PhoneDto;
  DateAcquired: Date;
  DateRelinquished: Date;
  CurrentOwner: boolean;
}
