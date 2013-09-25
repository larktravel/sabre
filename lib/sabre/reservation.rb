module Sabre
  class Reservation
    def self.book(session, room_code, line_number, unit_count, guest_count, amount, currency, name, card_code, card_number, expire_date, check_in, check_out, confirmation_number, memo )
      client = Sabre.client('OTA_HotelResLLS2.1.1RQ.wsdl')
      response = client.request('OTA_HotelResRQ', Sabre.request_header('2.1.1')) do
        Sabre.namespaces(soap)
        soap.header = session.header('Hotel Booking','sabreXML','OTA_HotelResLLSRQ')
        soap.body = {
          'Hotel' => {
            'BasicPropertyInfo' => '', #{ 'ConfirmationNumber' => confirmation_number },
            'Guarantee' => {
              'CC_Info' => {
                'PaymentCard' => '',
                'PersonName' => {
                  'Surname' => name
                },
                :attributes! => { 'PaymentCard' => { 'Code' => card_code, 'ExpireDate' => expire_date.strftime('%Y-%m'), 'Number' => card_number } }

              }
            },
            'GuestCounts' => '',
            #'POS' => Sabre.pos,
            #'RatePlanCandidates' => { 'ContractNegotiatedRateCode' => rate_code },
            'RoomType' => '',
            'SpecialPrefs' => {
              'Text' => memo
            },
            #'TimeSpan' => '',
            :attributes! => {
              'BasicPropertyInfo' => { 'RPH' => line_number },
              'Guarantee' => { 'Type' => 'G' }, # Took out GDPST
              'GuestCounts' => { 'Count' => guest_count },
              'RoomType' => { 'NumberOfUnits' => unit_count } #, 'RoomTypeCode' => room_code },
              #'TimeSpan' => { 'End' => check_out.strftime('%m-%d'), 'Start' => check_in.strftime('%m-%d') }
            }
          }
      }
      end
      result = response.to_hash[:ota_hotel_res_rs]
      raise SabreException::ConnectionError, Sabre.error_message(result) if result[:errors]
      return response
    end

    def self.confirm(session, full_name)
      client = Sabre.client('EndTransactionLLS2.0.2RQ.wsdl')
      response = client.request('EndTransactionRQ', Sabre.request_header('2.0.2', false)) do
        Sabre.namespaces(soap)
        soap.header = session.header('End Transaction','sabreXML','EndTransactionLLSRQ')
        soap.body = {
          'EndTransaction' => '',#{ 'Email' => '',#{ 'Itinerary' => { 'PDF' => '', :attributes! => { 'PDF' => { 'Ind' => 'true' } } },
                                             #:attributes! => { 'Itinerary' => { 'Ind' => 'true' } }
                                             #},
          #                        :attributes! => {'Email' => {'Ind' => 'true'} }
          #},
          'Source' => '',
          :attributes! => { 'EndTransaction' => { 'Ind' => 'true' }, 'Source' => { 'ReceivedFrom' => 'SWS TEST' } }
        }
      end
    end

    def self.cancel_stay(session,reservation_id = '1')
      client = Sabre.client('OTA_CancelLLS2.0.0RQ.wsdl')
      response = client.request('OTA_CancelRQ', Sabre.request_header('2.0.0')) do
      Sabre.namespaces(soap)
      soap.header = session.header('Cancel Reservation','sabreXML','OTA_CancelLLSRQ')
      soap.body = {
        'Segment' => '', :attributes! => { 'Segment' => { 'Number' => reservation_id } }
	    }
      end
    end
  end
end
